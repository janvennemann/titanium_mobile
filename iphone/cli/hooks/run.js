/* eslint-disable security/detect-non-literal-regexp */

/*
 * run.js: Titanium iOS CLI run hook
 *
 * Copyright (c) 2012-2017, Appcelerator, Inc.  All Rights Reserved.
 * See the LICENSE file for more information.
 */

'use strict';

const appc = require('node-appc'),
	ioslib = require('ioslib'),
	i18n = appc.i18n(__dirname),
	__ = i18n.__,
	__n = i18n.__n;

const spawn = require('child_process').spawn;

exports.cliVersion = '>=3.2';

exports.init = function (logger, config, cli) {
	cli.addHook('build.post.compile', {
		priority: 10000,
		post: function (builder, finished) {
			if (cli.argv.target !== 'simulator') {
				return finished();
			}

			if (cli.argv['build-only']) {
				logger.info(__('Performed build only, skipping running of the application'));
				return finished();
			}

			logger.info(__('Launching iOS Simulator'));

			let simStarted = false;
			const endLogTxt = __('End simulator log');

			function endLog() {
				if (simStarted) {
					logger.log(('-- ' + endLogTxt + ' ' + (new Array(75 - endLogTxt.length)).join('-')).grey + '\n');
					simStarted = false;
				}
			}

			const sim = ioslib.simulator
				.launch(builder.simHandle, {
					appPath:            builder.xcodeAppDir,
					focus:              cli.argv['sim-focus'],
					iosVersion:         builder.iosSdkVersion,
					killIfRunning:      false, // it will only kill the simulator if the device udid is different
					launchBundleId:     cli.argv['launch-bundle-id'],
					launchWatchApp:     builder.hasWatchApp && cli.argv['launch-watch-app'],
					launchWatchAppOnly: builder.hasWatchApp && cli.argv['launch-watch-app-only'],
					watchHandleOrUDID:  builder.watchSimHandle,
					watchAppName:       cli.argv['watch-app-name']
				})
				.on('log', function (msg, simHandle) {
					// system log messages
					logger.trace(('[' + simHandle.appName + '] ' + msg).grey);
				})
				.on('log-debug', function (msg) {
					// ioslib debug messages
					logger.trace(('[ioslib] ' + msg.replace('[DEBUG] ', '')).grey);
				})
				.on('log-error', function (msg, simHandle) {
					// system log error messages
					logger.error('[' + simHandle.appName + '] ' + msg);
				})
				.on('app-started', function () {
					finished && finished();
					finished = null;
				})
				.on('app-quit', function (code) {
					if (code) {
						if (code instanceof ioslib.simulator.SimulatorCrash) {
							logger.error(__n('Detected crash:', 'Detected multiple crashes:', code.crashFiles.length));
							code.crashFiles.forEach(function (f) {
								logger.error('  ' + f);
							});
							logger.error(__n('Note: this crash may or may not be related to running your app.', 'Note: these crashes may or may not be related to running your app.', code.crashFiles.length) + '\n');
						} else {
							logger.error(__('An error occurred running the iOS Simulator (exit code %s)', code));
						}
					}
					endLog();
					process.exit(0);
				})
				.on('exit', function () {
					// no need to stick around, exit
					endLog();
					process.exit(0);
				})
				.on('error', function (err) {
					endLog();
					logger.error(err.message || err.toString());
					logger.log();
					process.exit(0);
				});

			const majorSimVersion = builder.simHandle.version.split('.')[0];
			const useLogStream = parseInt(majorSimVersion) >= 11;
			const appName = builder.tiapp.name;
			const logProcessor = new SyslogProcessor(appName, logger);
			if (useLogStream) {
				sim.on('launched', function () {
					const child = spawn('xcrun', [
						'simctl', 'spawn',
						builder.simHandle.udid,
						'log', 'stream',
						'--style', 'syslog',
						'--predicate', `process == "${appName}"`
					]);
					child.stdout.on('data', data => {
						data = data.toString();
						logProcessor.processLogs(data);
					});
				});
			} else {
				sim.on('log-raw', function (line) {
					logProcessor.processLogs(line);
				});
			}

			// listen for ctrl-c
			process.on('SIGINT', function () {
				logger.log();
				endLog();
				process.exit(0);
			});
		}
	});
};

class SyslogProcessor {
	constructor(projectName, logger) {
		this.projectName = projectName;
		this.logger = logger;
		this.currentLogLevel = 'debug';
		this.partialLine = null;
		this.logEntryPattern = /.*?\s([^\s]+)(?:\([^\s]\))?\[\d+\]:(?:\s\(([^\s]+)\))?\s(.*)$/;
		this.logLevelPattern = new RegExp(`^\\[(${logger.getLevels().join('|')})\\]\\s`, 'i');
		this.captureActive = false;
		this.currentSourceHint = null;
	}

	processLogs(data) {
		const lines = data.split('\n');
		const lastLineIsPartial = data[data.length - 1] !== '\n';
		const skipLastLine = lines.length > 0 ? lastLineIsPartial : false;
		for (let i = 0; i < lines.length; i++) {
			let line = lines[i];

			if (this.partialLine) {
				line = this.partialLine + line;
				this.partialLine = null;
			}

			if (i === lines.length - 1 && skipLastLine) {
				this.partialLine = line;
				break;
			}

			const logEntryMatch = this.logEntryPattern.exec(line);
			if (logEntryMatch) {
				let appName = logEntryMatch[1];
				this.captureActive = this.projectName === appName;
				this.currentSourceHint = logEntryMatch[2];
			}

			if (!this.captureActive) {
				continue;
			}

			const isMultiline = logEntryMatch === null;
			let message = isMultiline ? line : logEntryMatch[3];
			if (!isMultiline && this.currentSourceHint === 'TitaniumKit') {
				const logLevelMatch = message.match(this.logLevelPattern);
				if (logLevelMatch) {
					this.currentLogLevel = logLevelMatch[1].toLowerCase();
					message = message.replace(logLevelMatch[0], '').trim();
				}
			}

			// trim trailing newline and restore ANSI colors
			message = message.replace(/\s$/g, '');
			if (message.length === 0) {
				continue;
			}
			message = message.replace(/\\\^\[\[(\d+m)/g, '\x1b[$1');

			if (this.currentSourceHint === 'TitaniumKit' || !this.currentSourceHint) {
				this.logger[this.currentLogLevel](message);
			} else {
				this.logger.trace(`(${this.currentSourceHint}) ${message}`.grey);
			}
		}
	}
}

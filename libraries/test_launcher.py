#!/usr/bin/env python3

""" 
Script for starting and closing Appium based Robot Framework tests more conveniently
than starting Robot Framework, Appium and other stuff manually.
"""

import argparse
import datetime
import importlib.util
import json
import os
import os.path
import pathlib
import re
import subprocess
import sys
import time

class TestLauncher:
    def __init__(self, args):
        self.app_path = args.app_path
        self.config = None
        self.config_file_argument = args.config_file
        self.config_file_path = None

        self.mode = args.mode
        self.include = args.include
        self.exclude = args.exclude
        self.dryrun = args.dryrun

    def set_and_validate_app_path(self):
        # First checking if app path was given at all
        if self.app_path == "None":
            return

            # Convering to absolute path, because appium wants absolute path.
        self.app_path = os.path.abspath(self.app_path)

        # Next validating the path.
        if not os.path.exists(self.app_path):
            raise ValueError("No app found in path: " + self.app_path)

    def check_argument_correctness(self):
        if self.mode == "start" or self.mode == "startandstop":
            self. set_and_validate_app_path()

    def generate_test_start_command(self):
        command = "robot"

        command += " " + self.get_robot_options_for_test_start_command()

        # Adding path from where to search for tests
        command += " ."
        return command

    def get_path_to_test_launhcers_folder(self):
        return pathlib.Path(__file__).parent.absolute()

    def get_path_to_variables_folder(self):
        current_working_directory = os.getcwd()
        return os.path.join(current_working_directory, "variables")

    def get_path_to_reports_folder(self,):
        current_working_directory = os.getcwd()
        folderpath = os.path.join(current_working_directory, "reports")

        config_file_filename = os.path.basename(self.config_file_path)
        config_stem = pathlib.Path(config_file_filename).stem
        device_name = re.sub(r"_variables$", "", config_stem)
        reports_path = os.path.join(folderpath, device_name)
        os.makedirs(reports_path, exist_ok=True)
        return reports_path

    def get_robot_options_for_test_start_command(self):
        """
        Return robot Framework arguments for starting test run
        """
        robot_args = ""
        robot_args += " --variablefile " + self.config_file_path

        test_reports_dir = self.get_path_to_reports_folder()
        robot_args += " --outputdir " + test_reports_dir
    
        # Resolve app path: use CLI argument if provided, otherwise fallback to config file
        app_to_use = self.app_path
        if self.app_path == "None" and hasattr(self.config, "app"):
            app_config = self.config.app
            # If app path is relative, resolve it relative to the config file's directory
            if not os.path.isabs(app_config):
                config_dir = os.path.dirname(self.config_file_path)
                app_to_use = os.path.abspath(os.path.join(config_dir, app_config))
            else:
                app_to_use = app_config
            print("App path not provided via CLI. Using app from config: " + str(app_to_use))
        
        robot_args += " -v app:" + app_to_use

        if self.include:
            for tag in self.include:
                robot_args += " --include " + tag
        if self.exclude:
            for tag in self.exclude:
                robot_args += " --exclude " + tag
        if self.dryrun:
            robot_args += " --dryrun"

        return robot_args

    def read_config_file(self):
        """" 
        Reads the config file
        """
        if os.path.exists(self.config_file_argument):
            self.config_file_path = self.config_file_argument
    
        else:
            variables_folder_absolute_path = self.get_path_to_variables_folder()
            path_to_try = os.path.join(variables_folder_absolute_path, self.config_file_argument)
            if os.path.exists(path_to_try):
                self.config_file_path = path_to_try
    
        # Reading config file dynamically.
        improvised_module_name = self.config_file_path
        spec = importlib.util.spec_from_file_location(improvised_module_name, self.config_file_path)
        config = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(config)
        self.config = config

    def start_appium(self):
        """ Starts appium with parameters given in config argument. """
        port = str(self.config.appium_port)
        command = "appium --port {0} --session-override".format(port)

        if hasattr(self.config, "default_capabilities"):
            default_caps = json.dumps(self.config.default_capabilities)
            command += " --default-capabilities '" + default_caps + "'"

        # Saving Appium log to log file and redirecting appium console output to nowhere.
        # This allows us to see only robot framework log in console
        time_string = datetime.datetime.now().strftime("%Y-%m-%d--%H-%M-%S")
        appium_log_path = os.path.join(self.get_path_to_reports_folder(), "appium-" + port + "-" + time_string + ".log")
        command += " --log {0}".format(appium_log_path)
        if sys.platform == "win32":
            command += " > NUL 2>&1"
        else:
            command += " > /dev/null 2>&1"

        print("")
        print("Starting Appium")
        print(command)
        subprocess.Popen(command, stdout=sys.stdout, shell=True)

        # Sleeping some time to allow appium to start before tests start.
        time.sleep(20)

    def start_emulator(self):
        avd_name = self.config.deviceName
        command = "emulator -avd {0} -no-snapshot-load".format(avd_name)
        print("")
        print("Starting emulator: " + avd_name)
        print(command)
        subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)

        # Wait for emulator to boot before starting Appium
        boot_command = "adb -s {0} wait-for-device shell getprop sys.boot_completed".format(self.config.udid)
        print("Waiting for emulator to boot...")
        for _ in range(30):
            result = subprocess.run(boot_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
            if result.stdout.decode().strip() == "1":
                print("Emulator booted.")
                break
            time.sleep(5)

    def start_tests(self):
        command = self.generate_test_start_command()

        print("")
        print("Starting Robot Framework")
        print(command)
        subprocess.run(command, stdout=sys.stdout, shell=True)

    def stop_appium(self):
        """ 
        Kills all appium instances 
        Works only on Mac for now. 
        Different command line commands needed for Windows.
        """
        print("")
        print("Stopping the appium instance running in port: " + str(self.config.appium_port))

        print("Searching for correct Process id")
        process_list = subprocess.run(
            ["ps", "aux"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=False,
        )

        matching_pids = []
        for line in process_list.stdout.splitlines():
            if "appium" not in line:
                continue
            if str(self.config.appium_port) not in line:
                continue
            if "grep" in line:
                continue

            columns = line.split(None, 10)
            if len(columns) > 1 and columns[1].isdigit():
                matching_pids.append(columns[1])

        if not matching_pids:
            print("No running Appium process found for port " + str(self.config.appium_port) + ". Continuing.")
            return

        for pid in matching_pids:
            print("Killing process with PID: " + pid)
            subprocess.run(["kill", pid], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)

    def stop_emulator(self):
        emu_kill_command = "adb -s {0} emu kill".format(str(self.config.udid))
        print("Killing emulator with command: " + emu_kill_command)
        emu_kill_process = subprocess.Popen(emu_kill_command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)

    def run(self):
        self.read_config_file()
        self.check_argument_correctness()

        if self.mode == "start" or self.mode == "startandstop":
            if self.config.is_emulator:
                self.start_emulator()
            self.start_appium()
            self.start_tests()

        if self.mode == "stop" or self.mode == "startandstop":
            self.stop_appium()

            if self.config.is_emulator:
                self.stop_emulator()
        
        print("All Done. Test launcher stopping.")

if __name__ == '__main__':
    desc = """ 
           This program is used to simplify starting or stopping following programs
           using configuration file and other arguments you provide.
           - appium
           - Android emulator
           - Robot Framework tests
           """
    parser = argparse.ArgumentParser(description=desc)
    parser.add_argument("--app-path", default="None", help="There are two options: \n " + 
                        "1. If you do not give this argument at all, the tests will use app that is already installed in the app. \n" +
                        "2. Second option is that you provide absolute or relative path (relative to location of mobile_test_launcher.py)" +
                        " to app that you want to use in testing.")
    parser.add_argument("--config-file", required = True,
                        help="Absolute or relative path (relative to current working directory) to configuration file." +
                        " If just the name of the configuration file is given" +
                        " and no configuration file is found at test_launcher's folder" +
                        " possible subfolder Tests/Varibles is checked as well.")
    parser.add_argument("--mode", default="startandstop", choices=["start", "stop", "startandstop"], 
                        help = "start starts appium and possible emulator and runs the tests."
                        + "stop stops the appium and possible emulator"
                        + "startandstop is the default option. It starts appium and possible emulator, runs the tests" +
                        " and then stops appium and possibl emulator.")
    parser.add_argument("--include", nargs="+", help="Robot Framework testcase tags to run. If not given, all test cases are run.")
    parser.add_argument("--exclude", nargs="+", help="Robot Framework testcase tags to not to run.")
    parser.add_argument("--dryrun", action="store_true", help="Runs Robot Framework in --dryrun mode.")
    args = parser.parse_args()

    tl = TestLauncher(args)
    tl.run()
    
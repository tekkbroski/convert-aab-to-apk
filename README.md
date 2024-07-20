# convert-aab-to-apk
This script simplifies the process of converting Android App Bundle (AAB) files to standard APK packages using the Bundletool command-line tool. This script automates the Bundletool command execution, making it easier to generate APK files from your AAB file for distribution and installation on Android devices

# Bundletool Installation and Usage Guide

This guide explains how to install bundletool on different operating systems and how to use the custom build script.

## Installing Bundletool

### Mac OS

1. Download the latest version of bundletool from the [official GitHub releases page](https://github.com/google/bundletool/releases).
   Look for a file named "bundletool-all-X.X.X.jar" where X.X.X is the version number.

2. Move the jar file to a directory in your system path:

   ``` bash
   sudo mv ~/Downloads/bundletool-all-X.X.X.jar /usr/local/bin/bundletool.jar
   ```

3. Create a shell script named `bundletool`:

   ``` bash
   sudo touch /usr/local/bin/bundletool
   sudo chmod +x /usr/local/bin/bundletool
   ```

4. Edit the shell script:

   ``` bash
   sudo nano /usr/local/bin/bundletool
   ```

   Add the following content:

   ```bash
   #!/bin/bash
   java -jar /usr/local/bin/bundletool.jar "$@"
   ```

5. Set permissions:

   ``` bash
   sudo chmod 755 /usr/local/bin/bundletool
   ```

### Linux

The process for Linux is similar to Mac OS:

1. Download the bundletool jar file.

2. Move it to a directory in your path, e.g., `/usr/local/bin`:

   ``` bash
   sudo mv bundletool-all-X.X.X.jar /usr/local/bin/bundletool.jar
   ```

3. Create a shell script named `bundletool` in the same directory:

   ``` bash
   sudo nano /usr/local/bin/bundletool
   ```

   Add the same content as in the Mac OS instructions.

4. Make the script executable:

   ``` bash
   sudo chmod +x /usr/local/bin/bundletool
   ```

### Windows

1. Download the bundletool jar file.

2. Create a new directory for bundletool, e.g., `C:\bundletool`.

3. Move the jar file to this directory and rename it to `bundletool.jar`.

4. Create a new batch file named `bundletool.bat` in the same directory with the following content:

   ```batch
   @echo off
   java -jar "%~dp0bundletool.jar" %*
   ```

5. Add the bundletool directory to your system PATH:
   - Right-click on 'This PC' or 'My Computer' and select 'Properties'.
   - Click on 'Advanced system settings'.
   - Click on 'Environment Variables'.
   - Under 'System variables', find and select 'Path', then click 'Edit'.
   - Click 'New' and add the path to your bundletool directory (e.g., `C:\bundletool`).

## Verifying the Installation

To verify the installation, open a new terminal (or command prompt on Windows) and run:

``` bash
bundletool version
```

This should display the version of bundletool you installed.

## Using the Custom Build Script

1. Clone the repository:

   ``` bash
   git clone https://github.com/tekkbroski/convert-aab-to-apk.git
   cd convert-aab-to-apk
   ```

2. Make the script executable (Mac/Linux only):

   ``` bash
   chmod +x bundletool_build.sh
   ```

3. Run the script:
   - On Mac/Linux:

     ``` bash
     ./bundletool_build.sh
     ```

   - On Windows:

     ``` bash
     bash bundletool_build.sh
     ```

4. Follow the prompts to:
   - Enable/disable universal mode
   - Optionally specify a directory for .aab and .apks files (press Enter to use current and parent directories)
   - Choose an .aab file from the current or parent directory
   - Optionally select an .apks file
   - Use an existing keystore or generate a new one
   - Provide necessary keystore details

5. The script will execute the bundletool command and optionally unpack the APKS file if requested.

Note: Ensure you have Java installed on your system before using bundletool or the build script.

## Security Note

If you choose to generate a new keystore, the script will create a file named `keystore_details.txt` containing sensitive information. Make sure to store this file securely and delete it after use. In a production environment, consider using more secure methods of key management.

PowerBuilder Foundation Classes

To get the PBLs, fork the project into your own workspace and then do a Connect to Workspace/Solution from the PowerBuilder IDE.  That will download all the source and create the PBLs with the latest changes.

<img width="802" height="91" alt="image" src="https://github.com/user-attachments/assets/9948fd63-e0dc-4406-9653-6027cc51effc" />

Once you have forked the project your copy will show you when we have made additional changes and you can sync your fork to update your copy.

<img width="1157" height="80" alt="image" src="https://github.com/user-attachments/assets/1a708200-0ddc-4355-9afe-9800447323bf" />

## Running the unit tests

The unit tests are in the `pfc_tests` project and use the [PBUnit2025](https://github.com/bruce-armstrong/PBUnit2025) framework, which is a git submodule at `tests\framework`.

Connect to Workspace/Solution does not download submodules. Instead it creates empty `pbunit.pbl`, `pbunitfunc.pbl` and `pbunitrunner.pbl` folders in `tests\framework`, and `pfc_tests` will not compile. To get the framework:

1. Delete the empty folders in `tests\framework`. Git will not download the submodule into a folder that has anything in it.
2. From the folder you connected to, run:

   ```
   git submodule update --init
   ```

3. Do a full rebuild of `pfc_tests` in PowerBuilder.

If you clone with git instead, use `git clone --recurse-submodules` and skip these steps.

To build and run the tests from the command line (requires PowerShell 7):

```
pwsh -File tests\run_tests.ps1
```

The script prints the results and writes `build\pfc_tests\results.xml` (JUnit format). It exits with 0 if all tests pass, 1 if any fail, and 2 if the build or run fails. Windows Smart App Control blocks the newly built test exe unless it is signed.

To add tests, see the framework's [README](https://github.com/bruce-armstrong/PBUnit2025#writing-tests).

If you would like to contribute to the project, please watch this video:

https://vimeo.com/478243534

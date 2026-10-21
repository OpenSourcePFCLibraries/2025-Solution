PowerBuilder Foundation Classes

To get the source code, fork the project into your own workspace and then use Github desktop to clone it to a local repo.  Then do an Open Solution from the PowerBuilder IDE to that location.

<img width="802" height="91" alt="image" src="https://github.com/user-attachments/assets/9948fd63-e0dc-4406-9653-6027cc51effc" />

Once you have forked the project your copy will show you when we have made additional changes and you can sync your fork to update your copy.

<img width="1157" height="80" alt="image" src="https://github.com/user-attachments/assets/1a708200-0ddc-4355-9afe-9800447323bf" />

## Running the unit tests

The unit tests are in the `pfc_tests` project and use the [PBUnit2025](https://github.com/bruce-armstrong/PBUnit2025) framework, which is a git submodule at `tests\framework`.

PowerBuilder's Connect to Workspace/Solution does not download submodules, so if you want to run the tests, get the source another way.

**Recommended: clone with GitHub Desktop, then open the solution**

1. In GitHub Desktop, use **File > Clone repository** to clone your fork. GitHub Desktop downloads the submodule along with the rest of the source.
2. In PowerBuilder, use **File > Open** to open `PFC.pbsln` from the cloned folder, instead of Connect to Workspace/Solution.
3. Do a full rebuild.

If you use git from the command line, `git clone --recurse-submodules` does the same as step 1.

**If you already used Connect to Workspace/Solution**

It creates empty `pbunit.pbl`, `pbunitfunc.pbl` and `pbunitrunner.pbl` folders in `tests\framework`, and `pfc_tests` will not compile. To get the framework:

1. Delete the empty folders in `tests\framework`. Git will not download the submodule into a folder that has anything in it.
2. Run the following in the folder you connected to. In GitHub Desktop, after **File > Add local repository**, **Repository > Open in Command Prompt** opens a command prompt there.

   ```
   git submodule update --init
   ```

3. Do a full rebuild of `pfc_tests` in PowerBuilder.

**A note on the framework libraries in PowerBuilder**

Until PowerBuilder supports git submodules, it shows `pbunitrunner.pbl`, `pbunit.pbl` and `pbunitfunc.pbl` as new, uncommitted objects. That is expected: the framework's files belong to the PBUnit2025 repository, and PFC records only which version of it to use. Do not add or commit these libraries from PowerBuilder. Changes to the framework go to the [PBUnit2025](https://github.com/bruce-armstrong/PBUnit2025) repository.

To build and run the tests from the command line (requires PowerShell 7):

```
pwsh -File tests\run_tests.ps1
```

The security service tests need a PFC security database. Set the environment variable `PFC_SECURITY_INI` to an INI file with the connection in a `[Security]` section (or set `PFC_SECURITY_SECTION` to another section name). The tests fail if it is not set. They roll back the rows they insert.

The script prints the results and writes `build\pfc_tests\results.xml` (JUnit format). It exits with 0 if all tests pass, 1 if any fail, and 2 if the build or run fails. Windows Smart App Control blocks the newly built test exe unless it is signed.

To add tests, see the framework's [README](https://github.com/bruce-armstrong/PBUnit2025#writing-tests).

If you would like to contribute to the project, please watch this video:

https://vimeo.com/478243534

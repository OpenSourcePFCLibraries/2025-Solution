PowerBuilder Foundation Classes

To get the source code, fork the project into your own workspace and then use Github desktop to clone it to a local repo.  Then do an Open Solution from the PowerBuilder IDE to that location.

<img width="802" height="91" alt="image" src="https://github.com/user-attachments/assets/9948fd63-e0dc-4406-9653-6027cc51effc" />

Once you have forked the project your copy will show you when we have made additional changes and you can sync your fork to update your copy.

<img width="1157" height="80" alt="image" src="https://github.com/user-attachments/assets/1a708200-0ddc-4355-9afe-9800447323bf" />

## Documentation

The PFC documentation (the User's Guide and the Object Reference, converted to Markdown and kept up to date) is in the [docs](https://github.com/OpenSourcePFCLibraries/docs) repository.

## Help files

The help files are not included in this repository.  Each one is published as a release in its own repository; download it and put it beside your application's exe:

- [pfcdlg.chm](https://github.com/OpenSourcePFCLibraries/PFCDLG-help-file-and-source/releases/latest/download/pfcdlg.chm): help for the PFC dialogs ([PFCDLG-help-file-and-source](https://github.com/OpenSourcePFCLibraries/PFCDLG-help-file-and-source/releases/latest))
- [PBPFC110.chm](https://github.com/OpenSourcePFCLibraries/Help-File-Source/releases/latest/download/PBPFC110.chm): the PFC help file, used by the security administrator ([Help-File-Source](https://github.com/OpenSourcePFCLibraries/Help-File-Source/releases/latest))
- [PFCEXAMP.chm](https://github.com/OpenSourcePFCLibraries/Example-application-help-file/releases/latest/download/PFCEXAMP.chm): help for the PFC example application ([Example-application-help-file](https://github.com/OpenSourcePFCLibraries/Example-application-help-file/releases/latest))
- [pfctutor.chm](https://github.com/OpenSourcePFCLibraries/PFCTUTOR-help-file-and-source/releases/latest/download/pfctutor.chm): help for the PFC tutorial ([PFCTUTOR-help-file-and-source](https://github.com/OpenSourcePFCLibraries/PFCTUTOR-help-file-and-source/releases/latest))

## Unit tests

The `pfc_tests` project contains unit tests that use the [PBUnit2025](https://github.com/bruce-armstrong/PBUnit2025) framework (a git submodule at `tests\framework`). To get the framework and run the tests, see [Running the PFC Unit Tests](https://github.com/OpenSourcePFCLibraries/docs/blob/main/unit-tests.md). In short, after cloning with GitHub Desktop or `git clone --recurse-submodules`:

```
pwsh -File tests\run_tests.ps1
```

If you would like to contribute to the project, please watch this video:

https://vimeo.com/478243534

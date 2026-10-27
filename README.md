PowerBuilder Foundation Classes

To get the source code, fork the project into your own workspace and then use Github desktop to clone it to a local repo.  Then do an Open Solution from the PowerBuilder IDE to that location.

<img width="802" height="91" alt="image" src="https://github.com/user-attachments/assets/9948fd63-e0dc-4406-9653-6027cc51effc" />

Once you have forked the project your copy will show you when we have made additional changes and you can sync your fork to update your copy.

<img width="1157" height="80" alt="image" src="https://github.com/user-attachments/assets/1a708200-0ddc-4355-9afe-9800447323bf" />

## The Examples app

The `pfc examples` project is a catalog of small windows that each show a PFC service at work.  See [examples/README.md](examples/README.md) for setting it up (the EASDEMO database and the images) and for the list of examples.

## Demo apps

- `openid demo`: signing in with an OpenID Connect identity provider (Authentik, Microsoft Entra ID, Google), the OAuth 2.0 flows, and PFC security from the provider's groups. See [openid demo/README.md](openid%20demo/README.md).
- `smtp demo`: sending mail with `n_smtpclient` and an OAuth 2.0 token. See [smtp demo/README.md](smtp%20demo/README.md).

## Documentation

The PFC documentation (the User's Guide and the Object Reference, converted to Markdown and kept up to date) is in the [docs](https://github.com/OpenSourcePFCLibraries/docs) repository.

## Help files

The help files are PDF files, and they are not included in this repository.  Download them and put them beside your application's exe:

- [pfcdlg.pdf](https://github.com/OpenSourcePFCLibraries/docs/raw/main/dialog-help/pfcdlg.pdf): help for the PFC dialogs, which their Help buttons open (built from the [dialog help](https://github.com/OpenSourcePFCLibraries/docs/tree/main/dialog-help) in the docs repository)
- [PFCEXAMP.pdf](https://github.com/OpenSourcePFCLibraries/Example-application-help-file/releases/latest/download/PFCEXAMP.pdf): help for the PFC example application ([Example-application-help-file](https://github.com/OpenSourcePFCLibraries/Example-application-help-file/releases/latest))
- [pfctutor.pdf](https://github.com/OpenSourcePFCLibraries/PFCTUTOR-help-file-and-source/releases/latest/download/pfctutor.pdf): help for the PFC tutorial ([PFCTUTOR-help-file-and-source](https://github.com/OpenSourcePFCLibraries/PFCTUTOR-help-file-and-source/releases/latest))

PFC's help service (`n_cst_help`, started with `gnv_app.of_SetHelp(True)`) shows a PDF help file at a topic, in a window of the application (`w_helpviewer`, with the Microsoft Edge WebView2 PDF viewer) or, with `gnv_app.inv_help.of_SetViewer(gnv_app.inv_help.PDFVIEWER)`, in the user's PDF viewer.  A topic is a named destination in the PDF file: `topic_<number>` for a help topic number, or a name, such as the PFC dialogs' `w_find`.  Compiled HTML Help (.chm) files are still shown with ShowHelp.

## Unit tests

The `pfc_tests` project contains unit tests that use the [PBUnit2025](https://github.com/bruce-armstrong/PBUnit2025) framework (a git submodule at `tests\framework`). To get the framework and run the tests, see [Running the PFC Unit Tests](https://github.com/OpenSourcePFCLibraries/docs/blob/main/unit-tests.md). In short, after cloning with GitHub Desktop or `git clone --recurse-submodules`:

```
pwsh -File tests\run_tests.ps1
```

To run them as a 64-bit executable as well (PFC calls Windows functions whose pointer and handle sizes differ between 32-bit and 64-bit):

```
pwsh -File tests\run_tests.ps1 -Platform 64
```

If you would like to contribute to the project, please watch this video:

https://vimeo.com/478243534

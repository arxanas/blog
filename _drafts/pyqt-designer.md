---
layout: post
title: Integrating Qt Designer with PyQt
permalink: pyqt-designer/
tags:
  - Python
  - Qt
---

* toc
{:toc}

# Introduction

There are several options to develop GUI apps in Python. One of these is with
the [Qt cross-platform framework][qt], and the [PyQt bindings]. One can find a
decent tutorial for using PyQt with Python here:
[http://zetcode.com/gui/pyqt5/](http://zetcode.com/gui/pyqt5/).

  [qt]: https://www.qt.io/
  [pyqt bindings]: https://pypi.python.org/pypi/PyQt5

Developing the entire UI for your application by writing out the code to lay out
all the controls is painstakingly slow. Instead, one can use [Qt Designer],
which is part of the [Qt Creator] IDE for Qt. But the IDE is designed for C++,
not Python. This post explains how to integrate Qt Designer with PyQt 5. It
assumes that you already have both these installed on your system.

  [qt designer]: http://doc.qt.io/qt-5/qtdesigner-manual.html
  [qt creator]: https://www.qt.io/ide/

{% aside A brief guide to installing these on OS X %}

I installed PyQt 5 and Qt Designer using [Homebrew] and [Homebrew Cask]. In
short, I issued these commands:

  [homebrew]: http://brew.sh/
  [homebrew cask]: https://caskroom.github.io/

```sh
$ brew install pyqt5 --with-python --without-python3
$ brew cask install qt-creator
```

Then I made a virtualenv for my project. To use PyQt 5 in this project with
Python 2, you can't just `pip install` it into your virtualenv; instead, you
must use the system version of it. With Homebrew, I had to add a `.pth` file to
my virtualenv:

```sh
$ echo 'import site; site.addsitedir("/usr/local/lib/python2.7/site-packages")' \
  >./.venv/lib/python-2.7/site-packages.pth
```

The instructions for you may be slightly different.

Once this all been done, you can verify that PyQt 5 is installed in your
virtualenv by importing it and confirming that there are no errors:

```sh
$ python
Python 2.7.11 (default, Jan 22 2016, 08:29:18)
[GCC 4.2.1 Compatible Apple LLVM 7.0.2 (clang-700.1.81)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import PyQt5
>>>
```

{% endaside %}

# About .ui files

Qt Designer uses `.ui` files to represent the GUI. These files are just XML
files with information about the window layout. We'd like to be able to somehow
access these files from Python and render them with Qt. Below is an example of
such a file, which you might want to use to follow along.

```xml
<ui version="4.0">
 <class>MainWindow</class>
 <widget class="QMainWindow" name="MainWindow" >
  <property name="geometry" >
   <rect>
    <x>0</x>
    <y>0</y>
    <width>400</width>
    <height>300</height>
   </rect>
  </property>
  <property name="windowTitle" >
   <string>Hello, world!</string>
  </property>
  <widget class="QMenuBar" name="menuBar" />
  <widget class="QToolBar" name="mainToolBar" />
  <widget class="QWidget" name="centralWidget" />
  <widget class="QStatusBar" name="statusBar" />
 </widget>
 <layoutDefault spacing="6" margin="11" />
 <pixmapfunction></pixmapfunction>
 <resources/>
 <connections/>
</ui>
```

There are a few ways to do this. One way is to include the file with your app,
and parse and render it at runtime using a library. Another way is to compile
them into Python classes ahead of time, and just include those Python source
files with your app. I used the second approach.

To do this, I used a package called `pyqt-distutils`. This package lets you
build your `.ui` files into Python classes as part of `setup.py`. The idea is to
keep the `.ui` files alongside their built `.py` files.

To set up my directory structure, I issued these commands:

```sh
$ mkdir -p myapp/gui
$ touch setup.py myapp/{__init__,__main__}.py myapp/gui/__init__.py
$ pbpaste >myapp/gui/mainwindow.ui  # paste in the above .ui file
$ tree
.
├── myapp
│   ├── __init__.py
│   ├── __main__.py
│   └── gui
│       ├── __init__.py
│       └── mainwindow.ui
└── setup.py

2 directories, 5 files
```

# Setting up pyqt-distutils

First, install the package:

```
$ pip install pyqt-distutils
```

Now, we need to make a configuration file. Fortunately, the package comes with a
command-line utility to help us. Create the configuration file:

```sh
$ pyuicfg -g --pyqt5
pyuic.json generated
$ cat pyuic.json
{
    "files": [],
    "hooks": [],
    "pyrcc": "pyrcc5",
    "pyrcc_options": "",
    "pyuic": "pyuic5",
    "pyuic_options": "--from-import"
}
```

Next, we need to add the `.ui` files to be built. Update `pyuic.json` to have
this entry in `files`:

```json
{
    "files": [
        [
            "myapp/gui/*.ui",
            "myapp/gui"
        ]
    ],
    "hooks": [],
    "pyrcc": "pyrcc5",
    "pyrcc_options": "",
    "pyuic": "pyuic5",
    "pyuic_options": "--from-import"
}
```

The first entry in the sublist is the file to build, and the second entry is the
directory to put the built file in. In my case, I just stored the built files
right alongside the `.ui` files.

Finally, we need to add a command to actually build the `.ui` files. This is the
suggestion [from the documentation][pyqt-distutils-docs], to be added to
`setup.py`:

  [pyqt-distutils-docs]: https://pypi.python.org/pypi/pyqt-distutils

```python
from setuptools import setup

try:
    from pyqt_distutils.build_ui import build_ui
    cmdclass = {"build_ui": build_ui}
except ImportError:
    cmdclass = {}

setup(
    name="myapp",
    version="0.1",
    packages=["myapp"],
    cmdclass=cmdclass,
)
```

Run the `build_ui` command:

```sh
$ python setup.py build_ui
running build_ui
pyuic5 --from-import /Users/waleed/Workspace/python/pyqt-test/myapp/gui/mainwindow.ui -o /Users/waleed/Workspace/python/pyqt-test/myapp/gui/mainwindow_ui.py
$ tree
.
├── myapp
│   ├── __init__.py
│   ├── __main__.py
│   └── gui
│       ├── __init__.py
│       ├── mainwindow.ui
│       └── mainwindow_ui.py
├── pyuic.json
└── setup.py

2 directories, 7 files
```

As you can see, it generated the `mainwindow_ui.py` file. Since this is
generated code, you may want to add it to your `.gitignore` or similar.

# Launching the app

Once the `.ui `files are built, you need to import the created classes into your
own code to use them. Put this content into `myapp/__main__.py`:

```python
import sys

from PyQt5.QtWidgets import QApplication, QMainWindow

from .gui.mainwindow_ui import Ui_MainWindow

class MainWindow(QMainWindow, Ui_MainWindow):
    pass

def main():
    app = QApplication(sys.argv)
    main_window = MainWindow()
    main_window.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
```

Install your app and launch it:

```sh
$ ls -1  # should be in the directory with setup.py
myapp
pyuic.json
setup.py
$ pip install -e .
Obtaining file:///Users/waleed/Workspace/python/pyqt-test
Installing collected packages: myapp
  Running setup.py develop for myapp
Successfully installed myapp-0.1
$ python -m myapp
```

{% image working-qt-app.png
         "The working, wholly featureless Qt app." %}

# Using Qt Designer

Once all this is set up, we just need to use Qt Designer to modify the `.ui`
file for us, so that we can rebuild it and have it appear in our app.

{% aside Trouble with setting up Qt Creator with Homebrew's Qt %}

When I launched Qt Creator for the first time, it told me that it wasn't able to
find a "kit" to use. To fix this, I added a Qt version by navigating to the
directory of the `qmake` executable that Homebrew installed, then I updated the
default Qt kit to use that Qt version.

{% image qt-versions.png
         "The Qt version configuration. I added the path to `qmake`." %}

{% image qt-kits.png
         "Then I updated this kit to use that Qt version." %}

{% endaside %}

Launch Qt Creator, click `File > Open File or Project...`, and select your `.ui`
file. (Do not try to create a project of any sort.) It should appear in Qt
Creator for you to edit and save. That's it!

{% image welcome-screen.png
         "The welcome screen for Qt Creator." %}

{% image editor.png
         "Qt Designer's UI editor." %}

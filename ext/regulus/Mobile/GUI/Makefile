# Include the common variables.

include $(MAEMO_ISSCO_HOME)/Common/Makefile.variables

# Include ACE macros and targets

include $(ACE_ROOT)/include/makeinclude/wrapper_macros.GNU
include $(ACE_ROOT)/include/makeinclude/macros.GNU
include $(ACE_ROOT)/include/makeinclude/rules.common.GNU
include $(ACE_ROOT)/include/makeinclude/rules.nonested.GNU
include $(ACE_ROOT)/include/makeinclude/rules.bin.GNU
include $(ACE_ROOT)/include/makeinclude/rules.local.GNU

#
# Module name.
#

MODULE_NAME = GUI

# Header related definitions.

EXPORTED_HEADERS = \
		GlobalDefs.hpp \
		GUIController.hpp \
		GUIWindow.hpp \
		GUIWindowObserver.hpp \
		UiDialogs.hpp
		
		
# Library related definitions.

LIB_NAMES = BaseGUI

LIB_BaseGUI_SOURCES = \
		$(SRCDIR)/GUIController.cpp \
		$(SRCDIR)/GUIWindow.cpp \
		$(SRCDIR)/test.cpp \
		$(SRCDIR)/UiDialogs.cpp

LIB_BaseGUI_LDFLAGS = -lSDL_net -lACE -lasound

# Executable related definitions.

EXE_NAMES = test_gui

EXE_test_gui_SOURCES = $(SRCDIR)/test.cpp
EXE_test_gui_LDFLAGS = -lBaseGUI -lCommunicationChannel -lACE -lasound \
		       	-lm -ldl -lrt -lgthread-2.0 \
			-lhildon_1 -lgtk-x11-2.0 \
			-lgdk-x11-2.0 -latk-1.0 \
			-lgdk_pixbuf-2.0 -lm -lpangoxft-1.0 \
			-lpangox-1.0 -lpango-1.0 \
			-lgobject-2.0 -lgmodule-2.0 \
			-ldl -lglib-2.0

# Additional attributes

ADDITIONAL_CCFLAGS 		= 
ADDITIONAL_CXXFLAGS 	= 	-I/usr/include/SDL -I/usr/local/include/SDL -I$(ACE_ROOT)\
				-ansi -I/usr/include/gtk-2.0 \
				-I/usr/lib/gtk-2.0/include \
				-I/usr/include/atk-1.0 \
				-I/usr/include/pango-1.0 \
				-I/usr/include/freetype2 \
				-I/usr/include/glib-2.0 \
				-I/usr/lib/glib-2.0/include \
				-I/usr/include/cairo \
				-I/usr/include/hildon-1
ADDITIONAL_LDFLAGS		=
ADDITIONAL_INCLUDES		=
ADDITIONAL_LIBRARIES	=	-L/usr/local/lib -L/usr/lib
# Include the common targets.

include $(MAEMO_ISSCO_HOME)/Common/Makefile.targets

__prebuild__:
		@-:

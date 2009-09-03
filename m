From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 03 Sep 2009 16:38:54 +0200
Subject: build system cleanup
Message-ID: <1251988734.339.111.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi guys,

before I start a crusade to do an overall clean up of the build system
(that IMHO is dusty and really needs some tidy up), I'd like to know
what's the team take on the subject and using automake and possibly
libtools.

I am not here to pick up a flamewar of what's best or worst.. just want
to know what the team wants.

the current autotools in F10:

autoconf-2.63-1.fc10.src.rpm
automake-1.11-2.fc10.src.rpm
libtool-1.5.26-4.fc10.src.rpm

and F11:

autoconf-2.63-2.fc11.src.rpm
automake-1.11-2.fc11.src.rpm
libtool-2.2.6-11.fc11.1.src.rpm

clearly libtool in F10 is not viable (simply too old) and I already have
a pretty good handle on 2.2.6 and higher for cluster related projects.

_theoretically_ running autoconf on F10 or F11 should make no difference
but that can be tested easily for regressions.

My suggestion would be to clean up in different steps, trying to avoid
one gigantic change:

1) we move to autoreconf on F11.
2) start cleanup of configure.in/configure.ac (the latter is now
preferred).
3) introduce automake (all Makefile.in will disappear in favour of
Makefile.am).
4) introduce libtool.

Clearly we stop at every single step for testing and extra cleanup,
splitting patches for easy review and so on.

Cheers
Fabio



From: Oliver Rath <rath@mglug.de>
Date: Mon, 25 Nov 2013 17:25:16 +0100
Subject: libcunit not found but installed [was Re: more complex example_cmdlib.c ? ]
In-Reply-To: <529378E3.10603@redhat.com>
References: <52935E70.6060705@mglug.de>	<52936896.8040905@redhat.com>	<52936FB7.9050803@mglug.de>	<529377F8.9090905@redhat.com>
	<529378E3.10603@redhat.com>
Message-ID: <529379EC.6070903@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek!

Am 25.11.2013 17:20, schrieb Zdenek Kabelac:
> Dne 25.11.2013 17:16, Zdenek Kabelac napsal(a):
> [..]
> You need devel packages for cunit if you want to link it.
>
was already installed:

lvm2$ dpkg-query -l libcunit1-dev
Gew?nscht=Unbekannt/Installieren/R=Entfernen/P=Vollst?ndig L?schen/Halten
| Status=Nicht/Installiert/Config/U=Entpackt/halb konFiguriert/
         Halb installiert/Trigger erWartet/Trigger anh?ngig
|/ Fehler?=(kein)/R=Neuinstallation notwendig (Status, Fehler:
GROSS=schlecht)
||/ Name                     Version                  Beschreibung
+++-========================-========================-================================================================
ii  libcunit1-dev            2.1-0.dfsg-9             Unit Testing
Library for C -- development files

lvm2$ dpkg-query -L libcunit1-dev
/.
/usr
/usr/share
/usr/share/doc
/usr/share/doc/libcunit1-dev
/usr/share/doc/libcunit1-dev/changelog.gz
/usr/share/doc/libcunit1-dev/NEWS.gz
/usr/share/doc/libcunit1-dev/AUTHORS
/usr/share/doc/libcunit1-dev/TODO
/usr/share/doc/libcunit1-dev/README.Debian-source
/usr/share/doc/libcunit1-dev/copyright
/usr/share/doc/libcunit1-dev/changelog.Debian.gz
/usr/share/doc/libcunit1-dev/README.gz
/usr/share/man
/usr/share/man/man3
/usr/share/man/man3/CUnit.3.gz
/usr/include
/usr/include/CUnit
/usr/include/CUnit/CUError.h
/usr/include/CUnit/CUnit.h
/usr/include/CUnit/MyMem.h
/usr/include/CUnit/TestDB.h
/usr/include/CUnit/TestRun.h
/usr/include/CUnit/Util.h
/usr/include/CUnit/Basic.h
/usr/include/CUnit/Console.h
/usr/include/CUnit/Automated.h
/usr/lib
/usr/lib/libcunit.a
/usr/lib/libcunit.la
/usr/lib/libcunit.so


Whats now?

Regards,
Oliver



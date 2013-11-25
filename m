From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Nov 2013 17:30:35 +0100
Subject: libcunit not found but installed [was Re: more complex example_cmdlib.c ? ]
In-Reply-To: <529379EC.6070903@mglug.de>
References: <52935E70.6060705@mglug.de>	<52936896.8040905@redhat.com>	<52936FB7.9050803@mglug.de>	<529377F8.9090905@redhat.com>	<529378E3.10603@redhat.com>
	<529379EC.6070903@mglug.de>
Message-ID: <52937B2B.7040205@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.11.2013 17:25, Oliver Rath napsal(a):
> Hi Zdenek!
>
> Am 25.11.2013 17:20, schrieb Zdenek Kabelac:
>> Dne 25.11.2013 17:16, Zdenek Kabelac napsal(a):
>> [..]
>> You need devel packages for cunit if you want to link it.
>>
> was already installed:
>
> lvm2$ dpkg-query -l libcunit1-dev
> Gew?nscht=Unbekannt/Installieren/R=Entfernen/P=Vollst?ndig L?schen/Halten
> | Status=Nicht/Installiert/Config/U=Entpackt/halb konFiguriert/
>           Halb installiert/Trigger erWartet/Trigger anh?ngig
> |/ Fehler?=(kein)/R=Neuinstallation notwendig (Status, Fehler:
> GROSS=schlecht)
> ||/ Name                     Version                  Beschreibung
> +++-========================-========================-================================================================
> ii  libcunit1-dev            2.1-0.dfsg-9             Unit Testing
> Library for C -- development files
>
> lvm2$ dpkg-query -L libcunit1-dev
> /.
> /usr

>
> Whats now?
>



look into    config.log  output from configure for a problem.

Seems there is no support for  pk config in  Ubuntu package like in Fedora:

i.e.:
/usr/lib64/pkgconfig/cunit.pc

---
prefix=/usr
exec_prefix=/usr
libdir=/usr/lib64
includedir=/usr/include

Name: CUnit
Description: C Unit Testing Framework
Version: 2.1
Libs: -L${libdir} -lcunit
Cflags: -I${includedir}
---


So either write something like this for you systems - or send a patch
with enhanced detection for CUnit  for configure.in

Zdenek



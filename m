From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Nov 2013 17:20:51 +0100
Subject: libcunit not found but installed [was Re: more complex example_cmdlib.c ? ]
In-Reply-To: <529377F8.9090905@redhat.com>
References: <52935E70.6060705@mglug.de>
	<52936896.8040905@redhat.com>	<52936FB7.9050803@mglug.de>
	<529377F8.9090905@redhat.com>
Message-ID: <529378E3.10603@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.11.2013 17:16, Zdenek Kabelac napsal(a):
> Dne 25.11.2013 16:41, Oliver Rath napsal(a):
>> Hi Zdenek!
>>
>> Am 25.11.2013 16:11, schrieb Zdenek Kabelac:
>>> [..] Maybe look at  test subdir  - there  are some API tests and
>>> also some python scripts which are trying to exercise some
>>> supported pieces.
>>
>> I tried to install lvm with --enable-testing , but the needed cunit
>> seems not to be found on my ubuntu 12.04.3 System:
>>
>> lvm2# dpkg-query -l libcunit1
>> Gew?nscht=Unbekannt/Installieren/R=Entfernen/P=Vollst?ndig L?schen/Halten
>> | Status=Nicht/Installiert/Config/U=Entpackt/halb konFiguriert/
>>           Halb installiert/Trigger erWartet/Trigger anh?ngig
>> |/ Fehler?=(kein)/R=Neuinstallation notwendig (Status, Fehler:
>> GROSS=schlecht)
>> ||/ Name                     Version                  Beschreibung
>> +++-========================-========================-================================================================
>>
>> ii  libcunit1                2.1-0.dfsg-9             Unit Testing
>> Library for C
>>
>> lvm2# dpkg-query -L libcunit1
>> /.
>> /usr
>> /usr/share
>> /usr/share/doc
>> /usr/share/doc/libcunit1
>> /usr/share/doc/libcunit1/changelog.gz
>> /usr/share/doc/libcunit1/copyright
>> /usr/share/doc/libcunit1/changelog.Debian.gz
>> /usr/share/CUnit
>> /usr/share/CUnit/CUnit-List.dtd
>> /usr/share/CUnit/CUnit-List.xsl
>> /usr/share/CUnit/CUnit-Run.dtd
>> /usr/share/CUnit/CUnit-Run.xsl
>> /usr/share/CUnit/Memory-Dump.dtd
>> /usr/share/CUnit/Memory-Dump.xsl
>> /usr/lib
>> /usr/lib/libcunit.so.1.0.1
>> /usr/lib/libcunit.so.1
>>
>>
>> lvm2# ./configure --with-thin=internal --with-replicators=internal
>> --enable-udev_sync --enable-udev_rules --enable-python_bindings
>> --enable-applib --enable-cmdlib --enable-testing
>>
>>   [..]
>>
>> checking pkg-config is at least version 0.9.0... yes
>> checking for PKGCONFIGINIT... no
>> pkg-config initialized
>> checking for CUNIT... no
>> configure: error: Package requirements (cunit >= 2.0) were not met:
>>
>> No package 'cunit' found
>>
>> Consider adjusting the PKG_CONFIG_PATH environment variable if you
>> installed software in a non-standard prefix.
>>
>> Alternatively, you may set the environment variables CUNIT_CFLAGS
>> and CUNIT_LIBS to avoid the need to call pkg-config.
>> See the pkg-config man page for more details.
>>
>>
>> What is going wrong here? TFH!
>>
>>
>
> Google:
>
> https://launchpad.net/ubuntu/+source/cunit
>

You need devel packages for cunit if you want to link it.

Zdenek




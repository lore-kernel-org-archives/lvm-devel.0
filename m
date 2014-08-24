From: Oliver Rath <rath@mglug.de>
Date: Sun, 24 Aug 2014 16:08:45 +0200
Subject: --enable-nls broken?
Message-ID: <53F9F1ED.2060208@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

compiling the lvm-git from today with configure ... --enable-nls
produces an error on install:
...
make -C po install
make[1]: Entering directory `/root/.oliver/lvm2/po'
Installing translation files in /usr/share/locale
/usr/bin/install: cannot stat 'de.mo': No such file or directory
make[1]: *** [install] Error 1
make[1]: Leaving directory `/root/.oliver/lvm2/po'
make: *** [po.install] Error 2

Is this feature already useable/needed?

Tfh!
Oliver



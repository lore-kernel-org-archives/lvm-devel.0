From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Wed, 22 Dec 2010 14:49:01 +0100
Subject: Release tarballs location
Message-ID: <20101222144901.5d2bb8c7@surf>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

I am a contributor of Buildroot, a tool that allows to easily build
embedded Linux systems. We create recipes to cross-compile software
that are useful on embedded systems, and LVM2 is one of them.

Unfortunately, it looks like when a release is made, the tarball is
placed at ftp://sources.redhat.com/pub/lvm2/, but as once as a newer
release is made, the previous tarball is moved into
ftp://sources.redhat.com/pub/lvm2/old/. Unfortunately, this doesn't
work well with how embedded Linux build systems work, since they code
an URL and a version for each software they build. This is usually not
a problem, since most of the software tarballs are available from a
fixed location.

Would it be possible to change the release tarball location policy in
order not to move them ? If you really want to have only the latest one
in ftp://sources.redhat.com/pub/lvm2/, could you also put the latest
available version in ftp://sources.redhat.com/pub/lvm2/old/ at the
moment of the release ?

Thank you very much!

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com



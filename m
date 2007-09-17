From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 17 Sep 2007 20:04:24 +0100
Subject: RFC: testing framework
In-Reply-To: <87ejgxcxpn.fsf@rho.meyering.net>
References: <87y7f9krex.fsf@rho.meyering.net> <87ejgxcxpn.fsf@rho.meyering.net>
Message-ID: <20070917190424.GL18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 17, 2007 at 01:56:04PM +0200, Jim Meyering wrote:
> +++ b/test/Makefile.in
> @@ -0,0 +1,75 @@
> +#TEST_OPTS=--verbose --debug
> +SHELL_PATH ?= $(SHELL)
> +TAR ?= $(TAR)
> +RM ?= rm -f
> +
> +subdir := $(shell pwd|sed 's,.*/,,')
> +
> +srcdir = .
> +top_srcdir = ..
> +top_builddir = ..

I'd prefer to see this handled consistently across all our Makefiles.
Elsewhere we have srcdir = @srcdir@, for example.

> +dmdir = $(abs_top_srcdir)/../device-mapper
> +so_name = $(dmdir)/lib/ioctl/libdevmapper.so.1.02

Please avoid the 1.02 hard-coding:-)
(Include a symlink within the dm tree if you want at build time - maybe
from lib/libdevmapper.so -> ioctl/libdevmapper.so.*)

> +clean:
> +	rm -rf init.sh lvm-wrapper bin .bin-dir-stamp
> +
> +all: $(T)
> +.PHONY: $(T) clean

Last time I read the docs, they said .PHONY had to appear before
'clean:', not after it.

> +++ b/test/mkdtemp

Can these ugly infrastructure scripts be grouped together in a subdir?

> @@ -0,0 +1,107 @@
> +#!/bin/sh
> +# Create a temporary directory, sort of like mktemp -d does.
> +# Usage: mkdtemp /tmp phoey.XXXXXXXXXX

Where has this come from and has it been audited?  I get worried when I
see scripts like this that don't include any comments indicating that
security was the prime consideration, and doing our own audit would
be an unnecessary distraction.

I'd prefer not to have to ship (i.e. take responsibility for) a script
like this ourselves if we can avoid that.

> +++ b/test/t0000-basic.sh
> +lvm >/dev/null 2>&1

(How about using $LVM set to include the full path?)

> +# Protect ourselves from common misconfiguration to export
> +# CDPATH into the environment
> +unset CDPATH

I'd feel safer if this approach was inverted: clear all environment
variables except the few required for correct reproducible operation of
the tests.

The test preparation also needs to take steps to insulate itself
as far as possible from any 'real' lvm2 installation on the system.
This will also aid reproducibility.
E.g. I suggest it uses private directories instead of /etc/lvm and
/dev.

Alasdair
-- 
agk at redhat.com



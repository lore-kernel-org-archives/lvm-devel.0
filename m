From: Petr Rockai <prockai@redhat.com>
Date: Wed, 03 Mar 2010 14:09:41 +0100
Subject: [PATCH 7/9] Remove -rdynamic
In-Reply-To: <ebecbe28ecbdcddf14de15dc5ff4a2a6db0ddb98.1267529065.git.zkabelac@redhat.com>
	(Zdenek Kabelac's message of "Tue, 2 Mar 2010 13:07:25 +0100")
References: <cover.1267529065.git.zkabelac@redhat.com>
	<cover.1267529065.git.zkabelac@redhat.com>
	<ebecbe28ecbdcddf14de15dc5ff4a2a6db0ddb98.1267529065.git.zkabelac@redhat.com>
Message-ID: <87ocj5pn56.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

> This patch might be a bit contraversional. It removes -rdynamic from
> linking of lvm.statis and dmeventd.static. In my understanding
> this compiler flag (or "-Wl,--export-dynamic") is mainly useful
> for dynamic linked libraries. It should not be needed for linking
> of static binary. But I could be wrong here...
(1) From man: This option is needed for some uses of "dlopen" or to
allow obtaining backtraces from within a program.

(2) Also according to manual, you need -rdynamic to allow dlopen'd
things to use symbols from the "host" binary.

We probably need not be concerned with (2) since we don't dlopen in
lvm.static as far as I can tell. As for (1), as long as debuginfo (-g)
is available, this is, as far as I can tell, redundant. So it *should*
be safe to remove this.

Yours,
   Petr.



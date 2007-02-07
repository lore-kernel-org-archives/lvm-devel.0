From: dustin@v.igoro.us <dustin@v.igoro.us>
Date: Wed, 7 Feb 2007 16:15:41 -0600
Subject: shared segtypes loading
Message-ID: <20070207221541.GG29594@v.igoro.us>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I'm new to this list, but a longtime user of lvm.  My brief googling for
this problem turned up nothing, but if it has been discussed before,
please tell me to RTFA and I'll look harder.

I believe I may have found a bug in the dynamic loading of segtypes in
toolcontext.c.  I've posted a bunch of details at
  http://bugs.gentoo.org/show_bug.cgi?id=131662
but I'll summarize here to conserve your time.

When segtypes are loaded dynamically, _init_segtypes first adds them to
cmd->segtypes:

        list_add(&cmd->segtypes, &segtype->list);

and then iterates over that same list, looking for a duplicate name:

        list_iterate_safe(sgtl, tmp, &cmd->segtypes) {
                segtype2 = list_item(sgtl, struct segment_type);
                if (!strcmp(segtype2->name, segtype->name)) {
                        log_error("Duplicate segment type %s: "
                                  ...

from my understanding, under any circumstances that this code is executed, at
some point segtype2 == segtype, and thus the strcmp() returns zero.

I fixed this locally with a patch (attached to the above Gentoo ticket) tht
just moves the list_add() below the duplicate check.  This seems effective, but
the would-never-have-worked nature of this bug (and age of the relevant code)
makes me suspect I'm missing something.

Dustin



From: Brendan Heading <brendanheading@gmail.com>
Date: Tue, 15 Sep 2015 17:43:58 +0100
Subject: MUSL fun
Message-ID: <CA+BsyQ4tDvVFXyo2Po9jiFKVobaJhMy7PoxWjczT8KFK9BrXWQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello all,

When compiling against the musl C library, an issue comes up in
lib/commands/toolcontext.c. There's some logic that reopens and
updates stdin and stdout in the event that their file descriptors are
in O_WRONLY mode.

================
if (!_reopen_stream(stdin, STDIN_FILENO, "r", "stdin", &new_stream))
    goto_out;
stdin = new_stream;
================

musl's view is that stdin/stdout/stderr are read only and are never
meant to be replaced by programs, so they declare them as const, which
means the above section (and similar sections) don't compile.

In theory a straightforward fix would be to do something like:

if (!freopen(NULL, "r", stdin))
     goto out;

.. but I suspect there is a good reason why this isn't done. Can
anyone shed any light on this ? If not I will submit a patch.

regards

Brendan



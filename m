From: Petr Rockai <prockai@redhat.com>
Date: Mon, 18 Oct 2010 19:17:58 +0200
Subject: [PATCH] (DRAFT!) Fix a deadlock in CLVMD (possibly related to BZ 561226).
Message-ID: <874ocje7y1.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the signalling code (pthread_cond_signal/pthread_cond_wait) in the
pre_and_post_thread in clvmd is using the wait mutex (see man
pthread_cond_wait) incorrectly, and this can cause clvmd to completely
deadlock when the timing is right.

This was showing up on nevrast in buildbot. Possibly triggered by an
independent bug in my vgextend --restoremissing code that caused a
double unlock of orphans, which would *normally* be fairly harmless, but
it tripped this race. Was not happening on other machines...

Anyway, Milan says that this could be related to BZ 561226 where clvmd
runs into deadlocks as well. It may or may not be the same, but it is
quite likely that someone somewhere would run into the bug that this
patch is fixing as well.

NB., I only made very modest effort at checking if localsock.mutex was
not being used for anything else. Whoever ends up reviewing the code,
please make sure this is so! If the localsock.mutex is being used for
anything else, the patch could actually introduce some new bad
behaviours. In that case, just creating a new mutex in the same
structure just for the pre_and_post_thread would be necessary. But you
get the idea of the fix, anyway. (It is also recommended that the
reviewer spends a while reading pthread_cond_wait manpage, especially
the section about the mutex pointer, and also with a paper and pencil
sketching on how things could go wrong if the mutex is used incorrectly,
as in this case.)

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: clvmd.diff
Type: text/x-diff
Size: 1794 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101018/0f9bdb4d/attachment.bin>

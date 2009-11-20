From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 21 Nov 2009 00:11:19 +0100
Subject: [PATCH 4/5] lvm-stack-on-resume-and-suspend-failures
In-Reply-To: <1258752552-1589-4-git-send-email-snitzer@redhat.com>
References: <1258752552-1589-1-git-send-email-snitzer@redhat.com>
	<1258752552-1589-4-git-send-email-snitzer@redhat.com>
Message-ID: <4B072217.2070701@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 20.11.2009 22:29, Mike Snitzer napsal(a):
> Add missing 'stack;' for all suspend_lv and resume_lv callers.
> 

How about using some macro like:

#define test_stack(a...) \
	do { \
		if (!a) \
			stack; \
	} while(0);

Well the name is randomly picked - but it could make code more compact and
readable ?

Zdenek


> Signed-off-by: Mike Snitzer <snitzer@redhat.com>
> ---
>  lib/locking/locking.c   |    6 ++++--
>  lib/metadata/lv_manip.c |    3 ++-
>  lib/metadata/mirror.c   |    5 +++--
>  tools/lvchange.c        |    6 ++++--
>  tools/lvconvert.c       |    3 ++-
>  tools/lvresize.c        |    3 ++-
>  tools/pvmove.c          |   21 ++++++++++++++-------
>  tools/toollib.c         |   13 ++++++++++++-
>  8 files changed, 43 insertions(+), 17 deletions(-)
> 



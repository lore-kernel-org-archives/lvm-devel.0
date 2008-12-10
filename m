From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 10 Dec 2008 22:50:18 +0000
Subject: [PATCH 10/11] Remove redundant init_mirror_in_sync() call in init_lvm().
In-Reply-To: <1228932661-15662-10-git-send-email-dwysocha@redhat.com>
References: <1228932661-15662-1-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-2-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-3-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-4-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-5-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-6-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-7-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-8-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-9-git-send-email-dwysocha@redhat.com>
	<1228932661-15662-10-git-send-email-dwysocha@redhat.com>
Message-ID: <20081210225018.GF24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 10, 2008 at 01:11:00PM -0500, Dave Wysochanski wrote:
> _mirror_in_sync is statically initialized to 0 in lvm-globals.c,
> so no need to set it in init_lvm().  Only other callers that may
> set this are later in execution.
 
Can the statics be relied upon if a handle is created, then destroyed
then a new handle created within the same process?

It basically depends if that initial value is relied upon anywhere, or
if later code always sets this before using it.

Alasdair
-- 
agk at redhat.com



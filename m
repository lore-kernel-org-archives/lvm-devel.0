From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 10 Dec 2010 17:00:37 +0000
Subject: [PATCH 0/9] Udev latency
In-Reply-To: <cover.1291802397.git.zkabelac@redhat.com>
References: <cover.1291802397.git.zkabelac@redhat.com>
Message-ID: <20101210170036.GA27182@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 08, 2010 at 01:57:46PM +0100, Zdenek Kabelac wrote:
> WARNING  - Not a final patch - this is patch for discussion WARNING
 
We had a discussion about this yesterday.

Zdenek is working on an updated patchset which addresses all the issues
we could come up with.

Summary of the (revised) patchset:
- Reuse a single cookie for consecutive operations instead of creating
a new one every time.
- Release the cookie (with fs_unlock etc.) only when unlocking the VG (avoids
need for extra cluster message and avoids races between commands if it were
done later).  
- Only do the udev_wait when an 'immediate' dev is encountered during tree
processing (cmirror) and when an LV just activated needs to be opened (just
set_lv needs this).

Alasdair



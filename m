From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 29 Sep 2009 19:51:14 +0100
Subject: [PATCH] Test that all snapshots are not open before deactivating volume.
In-Reply-To: <1254235590-30312-1-git-send-email-snitzer@redhat.com>
References: <1254235590-30312-1-git-send-email-snitzer@redhat.com>
Message-ID: <20090929185114.GR5351@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 29, 2009 at 10:46:30AM -0400, Mike Snitzer wrote:
> Test that all snapshots are not open before deactivating volume.
 
Moved the new checks into a separate function and applied.

Alasdair



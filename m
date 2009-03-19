From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 19 Mar 2009 16:09:21 +0000
Subject: [PATCH] remove old backup file after renaming vg
In-Reply-To: <49C26A35.105@redhat.com>
References: <49C26A35.105@redhat.com>
Message-ID: <20090319160921.GV3063@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Mar 19, 2009 at 11:52:21AM -0400, Takahiro Yasui wrote:
> This patch removes an old backup file after renaming vg
> by the vgrename command.
 
Ack provided that an archive file with identical contents already
got created.

Alasdair
-- 
agk at redhat.com



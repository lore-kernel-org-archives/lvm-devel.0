From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 2 Apr 2009 15:36:11 +0100
Subject: [PATCH] fix cmd->cmd_line memory pool use
In-Reply-To: <49D4C983.1070002@redhat.com>
References: <49D4C983.1070002@redhat.com>
Message-ID: <20090402143611.GQ13664@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 02, 2009 at 04:19:47PM +0200, Milan Broz wrote:
> Do not use pointer from released memory pool (cmd->cmd_line).
 
Ack.

Alasdair
-- 
agk at redhat.com



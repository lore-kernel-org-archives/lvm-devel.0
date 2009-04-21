From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 21 Apr 2009 19:24:10 +0100
Subject: [PATCH v3] fix clvmd metadata backup
In-Reply-To: <49EDE73D.1020003@redhat.com>
References: <49DF2C8F.6040005@redhat.com> <49EDE73D.1020003@redhat.com>
Message-ID: <20090421182410.GH1332@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 21, 2009 at 05:33:17PM +0200, Milan Broz wrote:
> Fix remote metadata backup for clvmd
> Run backup of metadata on remote nodes in the
> same place like local node - when calling backup().
 
Ack for now - it needs some decent testing though (incl.
checking the 'description' field contents are accurate).

Eventually I'd like all the backups pushing through the
locking code, but that would mean passing the description
field around so we don't lose it.

Alasdair
-- 
agk at redhat.com



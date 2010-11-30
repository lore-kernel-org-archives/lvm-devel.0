From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 30 Nov 2010 11:04:28 +0000
Subject: [PATCH] Scan also special metadata areas (like metadata/dirs) in fmt_from_vgname
In-Reply-To: <20101130044337.GA18385@agk-dp.fab.redhat.com>
References: <4CEFD75D.6060509@redhat.com>
	<20101130044337.GA18385@agk-dp.fab.redhat.com>
Message-ID: <20101130110428.GA19659@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Nov 30, 2010 at 04:43:37AM +0000, Alasdair G Kergon wrote:
> record whether or not in-filesystem metadata
> is in use and if so avoid returning when memlock is also set.

_text_handler.scan could be changed between _text_scan and NULL
to signal this.

Alasdair



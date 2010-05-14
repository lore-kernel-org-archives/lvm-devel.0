From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 14 May 2010 11:40:02 +0100
Subject: [PATCH 1/1] Use /bin/bash instead of /bin/sh
In-Reply-To: <68fd26e48c7d6d792d4d1af9551a0ba070e022d4.1273825538.git.zkabelac@redhat.com>
References: <cover.1273825538.git.zkabelac@redhat.com>
	<68fd26e48c7d6d792d4d1af9551a0ba070e022d4.1273825538.git.zkabelac@redhat.com>
Message-ID: <20100514104002.GQ2377@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 14, 2010 at 10:28:25AM +0200, Zdenek Kabelac wrote:
> Use /bin/bash for scripts using bashisms.
> For all of them 'checkbashisms' command reports miscelanous things
> available only in nonstandard shell extensions like bash.
 
Please post the output so we can see.

Alasdair



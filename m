From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 13 Oct 2009 12:13:10 +0100
Subject: [PATCH 1/2] configure.in: don't set default file owner and group
In-Reply-To: <65a458b2db3a9e79318281c38f94672e4cc585dc.1255411547.git.fdinitto@redhat.com>
References: <1255411718-12077-1-git-send-email-fdinitto@redhat.com>
	<65a458b2db3a9e79318281c38f94672e4cc585dc.1255411547.git.fdinitto@redhat.com>
Message-ID: <20091013111310.GF16950@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 13, 2009 at 07:28:37AM +0200, Fabio M. Di Nitto wrote:
> Per discussion on lvm-devel mailing list and part of debian patch set,
> don't set defaults for owner and group, since nobody seems to use them, and
> still allow override.
 
Ack.

Alasdair



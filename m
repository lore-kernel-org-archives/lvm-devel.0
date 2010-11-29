From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:43:14 +0000
Subject: [PATCH 29/29] Check for NULL pointer
In-Reply-To: <5aaa9a83ca612d4594736d7b7c34dcd5adc0a611.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<5aaa9a83ca612d4594736d7b7c34dcd5adc0a611.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129214314.GM29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:33AM +0100, Zdenek Kabelac wrote:
> clangs is happier and check for non NULL options value.
> Report internal error in this case.
 
That one looks completely pointless to me.
(And if you did have it, the right place for it would be after the switch that
always sets it.)

Nack.

Alasdair



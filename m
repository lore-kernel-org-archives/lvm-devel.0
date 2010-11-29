From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 23:27:20 +0000
Subject: [PATCH 02/29] Fix check for empty system_dir
In-Reply-To: <4CEEED6B.4050606@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<cover.1290682013.git.zkabelac@redhat.com>
	<ced2653c100dd20c1ed531b6ce59ae14a7396b13.1290682013.git.zkabelac@redhat.com>
	<87vd3lmich.fsf@twilight.int.mornfall.net.>
	<4CEEED6B.4050606@redhat.com>
Message-ID: <20101129232719.GU29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> > In that case, please use !strlen(str), as that is much more readable.
> In this case I believe it's common practice not only in our source to check
> the first char for '\0' when checking for empty string - so are we planning to
 
We use *str or str[0] in lots of places - it's pretty common practice I think
and shouldn't really surprise anyone.  !strlen(str) is also fine by me
where that adds clarity.

Alasdair



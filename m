From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 19 May 2010 21:31:28 +0100
Subject: [PATCH] handle transient errors in lvconvert --repair
In-Reply-To: <87zkzv3aqq.fsf@twilight.int.mornfall.net.>
References: <87y6g99bbg.fsf@twilight.int.mornfall.net.>
	<87pr1kai2k.fsf@twilight.int.mornfall.net.>
	<87y6fxos3x.fsf@twilight.int.mornfall.net.>
	<4BEDD432.4010800@redhat.com> <4BF1CAD9.1050005@redhat.com>
	<87ljbg3xkt.fsf@twilight.int.mornfall.net.>
	<4BF3FE5C.8070906@redhat.com>
	<874oi34ubd.fsf@twilight.int.mornfall.net.>
	<4BF43FFD.30504@redhat.com>
	<87zkzv3aqq.fsf@twilight.int.mornfall.net.>
Message-ID: <20100519203128.GH3991@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 19, 2010 at 10:19:41PM +0200, Peter Rockai wrote:
> Notice how the parameter is named "log_count" -- I have assumed, given
> that elsewhere it is called "remove_log" that this has a reverse
> meaning. Wrong, it actually means the same thing as remove_log.
 
Our variable names are meant to be global.

> Ugh, nlc sounds like short for new_log_count to me, which is *extremely

Fix abbreviations you find like that too, please:)

Alasdair



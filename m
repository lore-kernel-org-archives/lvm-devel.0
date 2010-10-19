From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 19 Oct 2010 16:00:28 +0100
Subject: [PATCH] dmeventd -R (restart; BZ 454618)
In-Reply-To: <4CBDB06D.3010104@redhat.com>
References: <87sk0kncit.fsf@twilight.int.mornfall.net.>
	<BCC2498C-1B82-4462-A9FE-27823E22DEA2@redhat.com>
	<20101005234945.GG1200@agk-dp.fab.redhat.com>
	<87bp77l8j2.fsf@twilight.int.mornfall.net.>
	<4CBDB06D.3010104@redhat.com>
Message-ID: <20101019150028.GE3935@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 19, 2010 at 04:51:25PM +0200, Zdenek Kabelac wrote:
> these static are 0 by default.
 
Maybe, but please leave them as they are - removing the assignment
adds needless obfuscation for people who don't realise that:)

Alasdair



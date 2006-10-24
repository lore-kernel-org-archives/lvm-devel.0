From: Jonathan E Brassow <jbrassow@redhat.com>
Date: Tue, 24 Oct 2006 09:46:00 -0500
Subject: LVM2 ./WHATS_NEW man/lvchange.8 tools/args.h t ...
In-Reply-To: <453D5BA4.9000107@ce.jp.nec.com>
References: <20061023230356.28539.qmail@sourceware.org>
	<453D5BA4.9000107@ce.jp.nec.com>
Message-ID: <cb25965068fcc60d0dc73882c222e4a1@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Oct 23, 2006, at 7:17 PM, Jun'ichi Nomura wrote:

>> +		active = 1;
>> +	}
>
> This "active = 1" should be set only if info.exists is true,
> because lv_info() succeeds even if the lv is not activated.

I also think we lost the ability to distinguish between clustered 
(active = -1) and active (active = 1).

Agk, we can send you a patch that will apply on top of the current 
patch now in CVS.

  brassow



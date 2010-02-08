From: Milan Broz <mbroz@redhat.com>
Date: Mon, 08 Feb 2010 16:31:59 +0100
Subject: Suppress locking initialisation failure messages when --ignorelockingfailure is used
In-Reply-To: <20100208150911.GA24305@redhat.com>
References: <4B700EDC.7020505@redhat.com>
	<4B701284.1030606@redhat.com>	<20100208134605.GA16433@redhat.com>
	<4B702169.2000405@redhat.com>	<20100208145515.GB20595@redhat.com>
	<4B7027F4.6090307@redhat.com> <20100208150911.GA24305@redhat.com>
Message-ID: <4B702E6F.7050901@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/08/2010 04:09 PM, Mike Snitzer wrote:
>>> Shouldn't rc.sysinit's "vgchange -a y --ignorelockingfailure" come
>>> _after_ root's rw remount?
>>
>> Exactly. It should also start volume monitoring etc.
>>
>> Note that monitoring need rw access (at least for status log to syslog,
>> but also if it triggers some change, it will require real lock - to perform
>> repair, snapshot resize or other action; metadata backups etc).
> 
> The monitoring gets started, by the "lvm2-monitor" service, after
> rc.sysinit.  So we should be fine there.

I was just not sure if "vgchange -a y" here tries to start monitoring or not.
If so, what happens? (lvm2-monitor init rc skript then will just restart it?)
Is it what we want?

Milan



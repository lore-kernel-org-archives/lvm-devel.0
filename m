From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 21 Oct 2009 10:29:14 +0200
Subject: [PATCH 3/4] Edit udev rules to use new udev flags and a cleanup
In-Reply-To: <4ADC51B1.2040704@redhat.com>
References: <4ADC51B1.2040704@redhat.com>
Message-ID: <4ADEC65A.5030202@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/19/2009 01:46 PM, Peter Rajnoha wrote:
>     However, the use
>     of OPTIONS+="last_rule" is controversial and a source of potential disputes.
>     I'm still not convinced about withdrawing the last_rule, I'll probably ask someone
>     from udev directly to get the opinion...

Just for the record, the statement I got from Kay Sievers from udev about this is that
we shouldn't use the "last_rule" at all because it could create an "inconsistent behavior"
and it should be removed.

The truth is that with "last_rule" some of the problems could stay hidden forever, because
only when something really breaks, people will react promptly :) So if we're going to play
udev rules, others should play device-mapper rules as well and do not try to process dm
devices when they are instructed to do so by means of checking certain environment variables
we set for them.

(Basically, there are two options - either we check the state and use last_rule and other
rules won't be processed or we rely on others checking these flags/env vars.)

Any comments are welcome..

Peter



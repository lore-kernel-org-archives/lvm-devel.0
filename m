From: Milan Broz <mbroz@redhat.com>
Date: Wed, 24 Mar 2010 09:49:36 +0100
Subject: [PATCH v2] improve activation monitoring option processing
In-Reply-To: <1269372233-4199-1-git-send-email-snitzer@redhat.com>
References: <1269372233-4199-1-git-send-email-snitzer@redhat.com>
Message-ID: <4BA9D220.2070409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/23/2010 08:23 PM, Mike Snitzer wrote:
> Add "monitoring" option to "activation" section of lvm.conf
> 
> Have clvmd consult the lvm.conf "activation/monitoring" too.

I am not sure if this is correct, there is flag sent from
calling process. I think the process should not send
this flag in the first place and not read lvm.conf later.

and specifically NOT in do_lock_lv for every LV.

> Introduce toollib.c:get_activation_monitoring_mode().
> 
> Error out when both --monitor and --ignoremonitoring are provided.
> 
> Add --monitor and --ignoremonitoring support to lvcreate.  Update
> lvcreate man page accordingly.
> 
> Clarify that '--monitor' controls the start and stop of monitoring in
> the {vg,lv}change man pages.


Sorry if it is dumb question, but if user disables monitoring,
do we still emit "block_on_error" for mirror table?

If so, is it correct? When a fail happens mirror all IOs waits
for userspace to do something - but there is no monitoring active.

Probably ok if command run manually (like in itnitrd, because we later
start dmeventd in initscripts) but if it is disabled permanently in lvm.conf?

Milan



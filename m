From: Petr Rockai <prockai@redhat.com>
Date: Fri, 18 Nov 2011 10:52:42 +0100
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <20111116130734.GE3294@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Wed, 16 Nov 2011 13:07:34 +0000")
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
	<87ehx8xv43.fsf@aldalome.int.mornfall.net.>
	<20111116105953.GD3294@agk-dp.fab.redhat.com>
	<20111116130734.GE3294@agk-dp.fab.redhat.com>
Message-ID: <87y5vdwydx.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:

>    (new_size = old_size + amount_to_extend_by) > 
> 	old_size_in_use + ((100 + autoextend_percent) - autoextend_threshold) / (100+autoextend_percent) * (old_size + amount_to_extend_by)
>
> IOW we scale the parameters based on the amount currently in use.
>
> For example:
>
>     snapshot_autoextend_threshold = 70
>     snapshot_autoextend_percent = 20

[snip] This is all great, but completely besides the point. So let me
stress the point once more:

- snapshot DSO monitors a snapshot, getting its status line every 10
  seconds or so
- the DSO has *no access* to the policy variables, because it does not
  (and can not) read lvm.conf

The problem:

- to check whether anything needs to happen, lvextend needs to be
  executed (this is *expensive*, even if it decides no action needs to
  happen)

- if nothing needed to happen, we don't need to call lvextend until the
  utilisation has grown; *but* we don't know whether anything happened
  (without ENO_ACTION_NEEDED that is)

Alternative solutions:

- we can store the actual size of the snapshot returned by the status
  ioctl, and compare that instead of relying on lvextend to say
  ENO_ACTION_NEEDED; it's less elegant and requires more changes in
  code, but avoids ENO_ACTION_NEEDED; there is a subtle race condition
  involved, although most likely not important

- we could check whether percent usage decreased since the last
  time... all of the disadvantages of the above are retained, and
  additionally is unreliable... I would advise against this solution

All I need to know which of the possible solutions you want
implemented. The ENO_ACTION_NEEDED one (the one proposed) is most
elegant and least intrusive. All the others are basically a workaround
for lack of ENO_ACTION_NEEDED -- we go and try to figure out if anything
actually changed.

Petr


-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined



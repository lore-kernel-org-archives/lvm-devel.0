Received: from mail-pf1-f182.google.com (mail-pf1-f182.google.com [209.85.210.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9311186E5E
	for <lvm-devel@lists.linux.dev>; Fri, 13 Sep 2024 05:56:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726206970; cv=none; b=mM6PoGLBY+5QzRtl7PiV/fwpuqoUOVd2R6jjUZsn+UqDYEd/yD6erfkwZnLhqBVmmyUEfSU8LBOpi+QWDps8CkOkcwf/XDFDl7BX9ypToojnQdcYaThL9XdcIEGPf9s3cUUZwjSdmRiJcb/FAGNVoB1dEZGrvcFpxp+aRJC7DCo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726206970; c=relaxed/simple;
	bh=uCJLdRCKiYaGhlDGEvRxGhQzjxtuMDuWsghxaRqHYBI=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=j2zWzg+BLnUo7Sz6y8kK8/NsVEMChT4dF+rCbaK/ygyF3Ay16tN9/6TKtzV5VgwGmpm00WyZvnSY6Z3M1TUdy1Lvc46lEtXa1M2iLVAaEFQjb27pa+hS5Xr16G33U/edxBq7ffiVLgVtk/B2gnYLBxeY8xcjS9mkVrHR5vfD4bg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Ih6RqpUi; arc=none smtp.client-ip=209.85.210.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ih6RqpUi"
Received: by mail-pf1-f182.google.com with SMTP id d2e1a72fcca58-71798661a52so1353481b3a.0
        for <lvm-devel@lists.linux.dev>; Thu, 12 Sep 2024 22:56:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1726206968; x=1726811768; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=x76xxAR3OwbCZ60gdilXuNsAEcNhpB2OmzbO7xdd5iA=;
        b=Ih6RqpUiF2ADDJlEqMXNTgjL5SYqYn8rPXZT/hUxTH2/ZOPjD8GYF/pvcybZDLYPGn
         P9DXCvP0pDo7LiRaluDe/UVLltxhVy3vEWO/Kg/5iMOJB0xg1FW2nl4QPkuCWLqyvYmE
         3rS4XI6I8tkitnIQmbCpWdJa0eJA89NGLBHOdElUGVtMdq0xsXq/TffTHicPgf28/CqN
         hG3ei0kF1DHN4N8lXCi9RDw8sSUw+lT+8AjyWsFMFZeE/LB+7brTZFqFv1wBxu28Xzou
         SLRQWPl/dEtJcLXdyngZPeHItMdq/eMyAqpv+dC1pJ/KjIZ/n9jcWMDN0SUozwbOIQ6K
         g9lQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726206968; x=1726811768;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=x76xxAR3OwbCZ60gdilXuNsAEcNhpB2OmzbO7xdd5iA=;
        b=GdJLwEu0BeFIP11zyMQi+c9AQSfGXRPR/Hz3UrGXUQL6fqoUS3kNLqriUc3Mh078zT
         t7XNlgTYlsfSxeNk0kzcrh+XF4E44iWgvr7rtyunKZ9X4T6mt8uaLYDc8O/gdopyYPzs
         NHBCfDyTCB2FqmZWA7GZw7rZh1vi1dkueBzLQ0HDQOrz8MRsTzlOHLo8LpRSvci9oorD
         2yZyMPaEalwJBYKhToXjLAc5oGlQJFqfQReZSELB+1pCg+6ksKF/bPJS2JNbgEU4RiTZ
         jascydJGa4j1Rdg0xQlLoRuLlGvEf3Y2Pt0yobGBZKnAqRNR+RPkjugXrhUENk/4N+Tt
         rK2w==
X-Forwarded-Encrypted: i=1; AJvYcCUmJON0aj2zJRdyFnpV1bSaXWj1pczpaTb7qNfEshiwVH1Bmg+oVDbQhu7RdIRtrtXLJllqwndzYBg=@lists.linux.dev
X-Gm-Message-State: AOJu0YxI/wDTksUo9ZgX1agXImwEc9+hbQsvsX7whL8AO+Z/2iXxTPAu
	+kA6S2XslUJasDd3wtQnfEMsnfyZAaddGdDeNqd90FR33g5tvdyUHvMmeggBCM84tFH8mroqq6g
	XIzvHYTQ343QmZ5VzLT5IXhW162g=
X-Google-Smtp-Source: AGHT+IEURfKHqBWlzbG8D9xA4TaLK3mTr2LxYOrcZG+iqraSS5Lw+QwcyWlilVwsuaYgskI/XJY91c4KLMvx1al8RBg=
X-Received: by 2002:a05:6a00:2348:b0:719:24a3:2a8b with SMTP id
 d2e1a72fcca58-71926457378mr8598745b3a.12.1726206967948; Thu, 12 Sep 2024
 22:56:07 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
 <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com> <CAHJKXw1Xc7fabs=JOjgcuh8vTwkVMRvN2Mx9UO3Dfm8iZxxZ-w@mail.gmail.com>
 <CALjSBEu7FA7Fv87P51vkiL98jRG42R3rkf2RUuxTEjHoQHMwdA@mail.gmail.com>
 <CAFe+wq0NPWHwon2QWdfJ8BkzVzUnSfOzLQGxXNykUW6jzyDiuw@mail.gmail.com> <CALjSBEtiPbHVsyJnQDFzk-zwk843-8a7D75_s3yBBnjpZDgphw@mail.gmail.com>
In-Reply-To: <CALjSBEtiPbHVsyJnQDFzk-zwk843-8a7D75_s3yBBnjpZDgphw@mail.gmail.com>
From: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Date: Fri, 13 Sep 2024 11:25:56 +0530
Message-ID: <CAHJKXw3d8-9RVhEaZ5+GuSB3LfgBMoy9mkUXEAoqwPTJdjhrjw@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Ming Hung Tsai <mtsai@redhat.com>
Cc: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>, lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Ming,
I am still collecting results, so I will present findings that are
confirmed so far.
There is some good news too.

On Fri, Sep 13, 2024 at 1:11=E2=80=AFAM Ming Hung Tsai <mtsai@redhat.com> w=
rote:
>
> Hi,
>
> On Wed, Sep 11, 2024 at 12:05=E2=80=AFAM Lakshmi Narasimhan Sundararajan
> <lsundararajan@purestorage.com> wrote:
> >
> > Hi Ming,
> > Thanks for reaching out.
> >
> > It looks like at the moment, writes, reads and discards are in the
> > mix, with block sizes varying from 16K-128K on a thin pool with chunk
> > size 64K, pool capacity many TB.
> > multiple thin lvols in the pool(200G), and all of them are busy process=
ing IOs.
> > This is on a VM, and storage disks are from iscsi SAN, mpath, md array
> > acting as lvm pv,  over which a thin pools gets formed.
>
> Does the thin-pool run inside or outside the VM?  and how do the thin
> lvols receive IO?
> Do those thin lvols receive IOs from nested hypervisors?

node instance may not be VM; sorry if that additional detail misled you.
My application consumes block devices (thin devices) from the thin pool.
Data on the block device is immaterial.
My application performs IO operations directly to the thin device.


>
> > And while in this setup, and IOs in progress, power cycle tests are
> > attempted and after recovering end up with data loss.
>
> Do you perform power cycle tests on the host running thin-pool, or the
> hosts generating IO workloads?
> Could you please explain how you identified the data loss, given there
> might be async IO operations?

My application that is consuming the thin device pumps IO traffic
directly on the raw block device.
My application also keeps a journal record outside the thin pool and
after power recycled, reading the data back
did not guarantee sync consistency.

I wrote a sample program that is trying to recreate this outside my applica=
tion.
here it is: sulakshm/iotest: iotest (github.com)
I am still refining it, as I have not seen the problem with this tool yet.
But the logic is similar to how my application consumes thin dev; and
my app can reproduce this very easily.

As I said before, I am still collecting additional information from
many internal tests.
So far, I can see this problem even in 6.5 kernel.

The latest distro/linux kernel where this problem is seen.
> 6.5.0-15-generic #15~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan 12 18:54:=
30 UTC 2 x86_64 x86_64 x86_64 GNU/Linux


There is a workaround to this problem that is looking promising, tests
ongoing still.

The sync point from my application is a sync(fd) of the thin dev.
This has proven insufficient.
In addition, I had to perform "dmsetup suspend pool -> dmsetup resume pool"=
.
This guarantees sync point consistency.

I believe at this point, there are still some operations IOs that are
in the pool that are dependent on the thin dev and are not flushed to
disk.
Doing the above workaround does the additional job and guarantees the
sync consistency.

I wanted to write this summary with more data points, since I see you
are tracking and want to make progress,
I am giving out this early information.

I will follow up with additional notes, but from your end, I would
appreciate it if you could help with the issue and see how this
workaround and my initial analysis as to the likely reason could cause
this.

Regards

>
> > Our internal study is still evolving at the moment, I will share more
> > as I find more.
> > Switching to latest fedora 40 is a challenge for me, whats the next
> > distro you may have in mind? Maybe list a few so I can pick whats
> > easier my end.
> >
> > Regards
> >
> > On Tue, Sep 10, 2024 at 9:23=E2=80=AFPM Ming Hung Tsai <mtsai@redhat.co=
m> wrote:
> > >
> > > On Mon, Sep 9, 2024 at 10:53=E2=80=AFPM Lakshmi Narasimhan Sundararaj=
an
> > > <lns.myspace@gmail.com> wrote:
> > > >
> > > > On Mon, Sep 9, 2024 at 6:57=E2=80=AFPM Zdenek Kabelac <zdenek.kabel=
ac@gmail.com> wrote:
> > > > >
> > > > > Dne 08. 09. 24 v 3:37 Lakshmi Narasimhan Sundararajan napsal(a):
> > > > > > Hi Team,
> > > > > > Greetings!
> > > > > >
> > > > > > In my experiments with thin pool and power cycle tests, I find =
that
> > > > > > the inflight data has not been persisted, even if there is a sy=
nc
> > > > > > following write that got completed.
> > > > > >
> > > > > > suppose we have the following bdev stackup:
> > > > > > bdevs(multi) -> mpath -> lvm pv -> lvm vg -> lvm thin pool -> m=
ultiple
> > > > > > thin vols.
> > > > > >
> > > > > > Each of the thin vols that has inflight data, has a correspondi=
ng sync
> > > > > > checkpoint periodically. The expectation is all writes before t=
he sync
> > > > > > are persisted to disk and can survive power reset tests.
> > > > > >
> > > > > > Like below seq on many thin vols on the thin pool.
> > > > > > write -> write -> write -> fsync(fd) -> write -> write -> fsync=
(fd) -> ..etc
> > > > > >
> > > > > > Now my code only does a fsync(fd) on the thin volume (block dev=
ice directly).
> > > > > > There are no fs mounts on the volume.
> > > > > > Is this sufficient or should the thin pool (/dev/mapper/pool) a=
lso be
> > > > > > synced along?
> > > > > > What would be the proper sequence of sync actions to survive a =
power reset?
> > > > > >
> > > > > > I am also trying to validate if this is an issue because mpath =
is
> > > > > > involved in any way(another dm layer in between), but would app=
reciate
> > > > > > some guidance in this
> > > > > > regard.
> > > > >
> > > > > Hi
> > > > >
> > > > > Could you please retest your issue with  recent lvm2  (>=3D 2.03.=
24) and recent
> > > > > linux kernel   >=3D 6.9
> > > >
> > > > Thank you for your quick attention.
> > > >
> > > > That is a big jump.
> > > > Would you be willing to consider any distro (say OCP latest?), that
> > > > will come with a bundle for both lvm+kernel, is there any such
> > > > combination you would consider for this test?
> > > > Also, is there any way I can check issues/fixes of interest?
> > > >
> > > > Is my logic using fsync(thin pool device) sufficient to pass power =
fail tests?
> > > > Are there any stronger versions or more logic to ensure power reset=
 test passes?
> > > >
> > > > Regards
> > > >
> > > > >
> > > > > Regards
> > > > >
> > > > > Zdenek
> > > > >
> > > >
> > >
> > > Hi,
> > >
> > > Could you please provide more details on the steps you took that led
> > > to the issue?
> > > Additionally, if possible, it would be helpful to let us know if the
> > > issue is reproducible on Fedora 40, with or without the mpath layer.
> > >
> > >
> > > Thanks,
> > > Ming-Hung Tsai
> > >
> > >
> >
>

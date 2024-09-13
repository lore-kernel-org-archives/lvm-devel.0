Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61D6F6FB0
	for <lvm-devel@lists.linux.dev>; Fri, 13 Sep 2024 14:19:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726237156; cv=none; b=lfM5o9b1w18L4w12byc3tRShSYsTcRY4lskBGiaDfUgltBgBt+/0+hW92Y4KDLbrkk1X/HPewK+Smm/xH9iIf5uYJASNAuJ1FQgMoKOL8GmeJHxX7n7wQnTcxCE1vkqMlEfrLlyOi6tlfkAP34EcmDYJH4chPpXvlD6gLjFrWSQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726237156; c=relaxed/simple;
	bh=uihP3ucS8C+F46SFq6k8nHAXs2fFEfLg7LbNc1zY1hA=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=VmcS0Ldhhx6foaJIFTz+BxSaf8C/l1YLVO9fZawLID453Xcb4zIhpR2dj00TZ9gDYn61WtawPTUsY7T9wRmMDYiL1Gd3H4eqMIcthbpieRJvy4h6KGVwFOq1f9FKJKN+P+i1ikXEiwMMbNlwUtn5dQB86YcS3M0WYwA56QkOgks=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=EM55RuG7; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="EM55RuG7"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1726237153;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=nq/GIuz0JhI6nNZnoRbw4zzWyf2si5N8Ct5rQ+wTJvA=;
	b=EM55RuG73reDACcUo5H3/W/CtsZ7VIkV/IJsAgyLkQWsARYy/1uMft9q1LHv27mY0JeVEK
	tKxko/x8/eHWW79z4LpSbOD8z44AD4TB6BCOGYIgBESedDNyoo8aJxE7aK+PFe/tx/3+++
	LuMLU2gopHFWvEczG9BsyUlHRvwvYc8=
Received: from mail-oo1-f72.google.com (mail-oo1-f72.google.com
 [209.85.161.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-49-yE9SKb8GNoOq7cmrbM9trw-1; Fri, 13 Sep 2024 10:19:12 -0400
X-MC-Unique: yE9SKb8GNoOq7cmrbM9trw-1
Received: by mail-oo1-f72.google.com with SMTP id 006d021491bc7-5e1b5b8555fso693206eaf.0
        for <lvm-devel@lists.linux.dev>; Fri, 13 Sep 2024 07:19:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726237151; x=1726841951;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=nq/GIuz0JhI6nNZnoRbw4zzWyf2si5N8Ct5rQ+wTJvA=;
        b=hei91nVqckoRsFlcnhNTiH7PpzmQQzdxTfmhraCfVL5WErXlsDyrsy5EuVIiO45W2Y
         qyJtOtuHsoKiqol3DXHJe9wV+lcXOiC6ltmy763sf+K2/L5/eHBbZHT7VR8O2sZLehUQ
         poTTIKNOnj0TNzgHZu+n+AY/XixLI/Ah5P1pFEw0lGUS10Fkiq0y+9IgUZtD6cTNDs6T
         6aaz6DCQmKuPuDAfW+XyEKRkuJlZ+NnYLuFsjkkG2LS7rjSuuAYmbmTNx6XvCui7BRUJ
         ZPNgriamJ0NKHdstvVgT7dkBs6hJimnyv5/DPUd9yWMtO1Dsqlvtm1asKeYSv3RAeuzu
         htzg==
X-Forwarded-Encrypted: i=1; AJvYcCVjRaBSgWNMdQxapRSsJ5DCFulXYHfkjuy4/BgYcxp0jiEyVDQZgfwclymB4C7ZltB5PnJuoBc6lkY=@lists.linux.dev
X-Gm-Message-State: AOJu0Yxc/n5lJGY0AxBIEPQQK0UCrMoPG95CBH1iQynpYLZP1gqDQzoo
	HFaNPW9/vt9B7+oOJXw2vrtn045I1gKD2Ar2WibwHF4dkyWcfZCy1m9hrValguTt2dx3w6rLRDI
	9/aDWB38af5qihTY+rPFO+qRXnzFfp8i1TGJg4VEUg5sdIbsJPc2ipxNLQTHYsDtPLgKx7JtJID
	ki6iR3L7mP/gqJQboay8CxkfNNtCTlKwEa
X-Received: by 2002:a05:6820:1ad2:b0:5e1:dfc9:3ee6 with SMTP id 006d021491bc7-5e20c399420mr1695754eaf.4.1726237151518;
        Fri, 13 Sep 2024 07:19:11 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IGjhc0JiMDq4FZRcoP2Q6opZt2v2YqsEBE78I2j2UmsAoWZjmmCeDPaf+nKbj5FtVwFGJN3XeJO5Y7GNhzHEgA=
X-Received: by 2002:a05:6820:1ad2:b0:5e1:dfc9:3ee6 with SMTP id
 006d021491bc7-5e20c399420mr1695736eaf.4.1726237151195; Fri, 13 Sep 2024
 07:19:11 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
 <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com> <CAHJKXw1Xc7fabs=JOjgcuh8vTwkVMRvN2Mx9UO3Dfm8iZxxZ-w@mail.gmail.com>
 <CALjSBEu7FA7Fv87P51vkiL98jRG42R3rkf2RUuxTEjHoQHMwdA@mail.gmail.com>
 <CAFe+wq0NPWHwon2QWdfJ8BkzVzUnSfOzLQGxXNykUW6jzyDiuw@mail.gmail.com>
 <CALjSBEtiPbHVsyJnQDFzk-zwk843-8a7D75_s3yBBnjpZDgphw@mail.gmail.com>
 <CAHJKXw3d8-9RVhEaZ5+GuSB3LfgBMoy9mkUXEAoqwPTJdjhrjw@mail.gmail.com> <51fdc9a7-8639-4c1a-b8a5-c3be0a5a61f5@gmail.com>
In-Reply-To: <51fdc9a7-8639-4c1a-b8a5-c3be0a5a61f5@gmail.com>
From: Tony Asleson <tasleson@redhat.com>
Date: Fri, 13 Sep 2024 09:19:00 -0500
Message-ID: <CAPmdA5Yw+C-VTATaKJxQTsOrmYexKWiXHLK9+u7NNU1KF_D3Tg@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Cc: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>, Ming Hung Tsai <mtsai@redhat.com>, 
	Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>, lvm-devel@lists.linux.dev
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

You may want to check out https://lwn.net/Articles/457667/

On Fri, Sep 13, 2024 at 9:06=E2=80=AFAM Zdenek Kabelac <zdenek.kabelac@gmai=
l.com> wrote:
>
> Dne 13. 09. 24 v 7:55 Lakshmi Narasimhan Sundararajan napsal(a):
> > Hi Ming,
> > I am still collecting results, so I will present findings that are
> > confirmed so far.
> > There is some good news too.
> >
> > On Fri, Sep 13, 2024 at 1:11=E2=80=AFAM Ming Hung Tsai <mtsai@redhat.co=
m> wrote:
> >>
> >> Hi,
> >>
> >> On Wed, Sep 11, 2024 at 12:05=E2=80=AFAM Lakshmi Narasimhan Sundararaj=
an
> >> <lsundararajan@purestorage.com> wrote:
>
> > My application that is consuming the thin device pumps IO traffic
> > directly on the raw block device.
> > My application also keeps a journal record outside the thin pool and
> > after power recycled, reading the data back
> > did not guarantee sync consistency.
> >
> > I wrote a sample program that is trying to recreate this outside my app=
lication.
> > here it is: sulakshm/iotest: iotest (github.com)
> > I am still refining it, as I have not seen the problem with this tool y=
et.
> > But the logic is similar to how my application consumes thin dev; and
> > my app can reproduce this very easily.
> >
> > As I said before, I am still collecting additional information from
> > many internal tests.
> > So far, I can see this problem even in 6.5 kernel.
> >
> > The latest distro/linux kernel where this problem is seen.
> >> 6.5.0-15-generic #15~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri Jan 12 18:=
54:30 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
> >
> >
> > There is a workaround to this problem that is looking promising, tests
> > ongoing still.
> >
> > The sync point from my application is a sync(fd) of the thin dev.
> > This has proven insufficient.
> > In addition, I had to perform "dmsetup suspend pool -> dmsetup resume p=
ool".
> > This guarantees sync point consistency.
> >
>
> Hi
>
> Not exactly sure what your app is all exactly doing - however there is
> cut&paste from 'fsync()'  manpage:
>
> ---
> Calling fsync() does not necessarily ensure that the entry in the directo=
ry
> containing the file has also  reached  disk.   For  that  an  explicit
> fsync() on a file descriptor for the directory is also needed.
> ---
>
> For this purpose our 'test suite' app basically  'opens' whole device and
> fsync and close it - to ensure synchronization point flush.
>
> Thus 'suspend & resume' of the whole thin device could be possibly unnece=
ssary
> - just do a fsync() on blockdevice fd.
>
>
> You can also play fun games with 'fsfreeze' operation.
>
> Regards
>
> Zdenek
>
>
>


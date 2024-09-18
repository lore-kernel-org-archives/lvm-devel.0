Received: from mail-pj1-f46.google.com (mail-pj1-f46.google.com [209.85.216.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97BF8158522
	for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 10:47:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726656467; cv=none; b=uVGsKNBDef3h4w8l/2h4hfjk98fJeuuv/LhKfSD63cHQl6ZZUGZ0zXY0O6dAzybJPCOl6YieQI9q+0fmJ+pLB6I0d7GlMIHE0DGpzp3QH/xgTQ7OWs79pWblGtZ3W6CovYNOFwaFQYHVHpQsMmuxh4ne5anXhgMHspR1MjMc3x0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726656467; c=relaxed/simple;
	bh=N4ZMF7Xdm2D1ehjKf14f9LDvtpeFXl0p1sK/nq+nTw8=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=MGNPFnXMrCAJOI12fxrXY+v95+NCfx33/UtbiHVKDqra7J/QUE0f23cpDI1bRaBbRlBId/UQNOBXpDnnWgzicr5Frp3RomFpKdufUiyGKpdIOqoOft/xo2LCNlFH2N23URJJsPofVc7IPj2Xf7R2U3aRBhfqdL0rt/NO+mllMKE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com; spf=fail smtp.mailfrom=purestorage.com; dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b=Pfwsh9lJ; arc=none smtp.client-ip=209.85.216.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="Pfwsh9lJ"
Received: by mail-pj1-f46.google.com with SMTP id 98e67ed59e1d1-2db928dbd53so5530204a91.2
        for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 03:47:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1726656465; x=1727261265; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=SbVXi7YT5soxcTmB0RfaMtfjdGNRB1b4lwJTNWB8KZc=;
        b=Pfwsh9lJBZOB878fGEbGBLoA8RijsV+mr5VWu8ScsmK+8s+amO4pef2aLb2ydjgy8i
         rRdrGzkqdI86gF+9MSdsbutgcSpC2T3Z4L/ifrC7SWov5iG1QVnDKLzYtRDsL59U6NQ2
         BwdRg3rWcoXTrlxsustcYsi+cYSKo4EHsFPglb2m5+fbm42+DCOJNORxKLGVlxKEqjrY
         h5Bh/kDgrlvDKOHoVAcxmm1berQcgphmFtNnBYdtctNiQWT1pIf3iFRBiqAv8APB6BfV
         VIIGpsW0NudWomKRjfP9zA5BwsMMgOh6pt7XwG2/oo6STFkNq+cbR/86U+cQOZLasnAT
         IAyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726656465; x=1727261265;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=SbVXi7YT5soxcTmB0RfaMtfjdGNRB1b4lwJTNWB8KZc=;
        b=f63j7MVYwvohfXksHIuz3E79zp743X58PwPbxgIOOV4jEu1Pm5sCO4CMPOJ91tkdpw
         /+UfYXjtciDtzgULgW1dkH6LvY8uikxV6saK3Ih0XW2kv3GIfHofmHXFoan7PlJ3OKx4
         KFKFss6RMVkpRtSU3o7gROUQ4vdKBOZnHAWvSDg7iFi0mvIMVekMFtv+S8r+Tn/QlU5B
         Vj5N4sLcviyH3xG7bzNnJr8zJV0fDODxGsHrj/xq3xwXMdV2vWyUnDiouTFqEnQALcjF
         tENReJrVwj4JX/YjZYVZmg/l4gUdIlQNB2x224agqWr9jyAI+qC+TW+AC/GQbJWEoaDj
         1nsA==
X-Forwarded-Encrypted: i=1; AJvYcCU7FHQWvVHhD1oSGbc/0muaqqGBZkPKDrphkx8mczeTEnM+oneMFprMKTIDbKm+YXX3dGuJCq9O89w=@lists.linux.dev
X-Gm-Message-State: AOJu0Yz1V14qwV6omfhdzchHEXWSqtSE8CYPdRvpPlwRHmGVuUlrsaWd
	i5lhlenAOcZ+KIG4SNl4+lQMxxRbfmyitG5npvuzwDa8jCLjbE8U036Vg3t5FNJcGAi3AWbVGQ+
	sGF/u1JvrvlWGZN8Pxo6ugwxq97DQiHaoaMPxWg==
X-Google-Smtp-Source: AGHT+IHsO1Dx0HGF285Xf+tLWfyCaeiX3y+jMFT4lNZ/OGG0eM7b30OOAfvdIp1hHU+SsE3eulGzUXYBFve4kBN4Kpk=
X-Received: by 2002:a17:90a:4281:b0:2d8:8fe9:b015 with SMTP id
 98e67ed59e1d1-2dba008327cmr27700892a91.39.1726656464722; Wed, 18 Sep 2024
 03:47:44 -0700 (PDT)
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
 <CAHJKXw3d8-9RVhEaZ5+GuSB3LfgBMoy9mkUXEAoqwPTJdjhrjw@mail.gmail.com>
 <51fdc9a7-8639-4c1a-b8a5-c3be0a5a61f5@gmail.com> <CAPmdA5Yw+C-VTATaKJxQTsOrmYexKWiXHLK9+u7NNU1KF_D3Tg@mail.gmail.com>
 <CAHJKXw2jCEGFsb+EveUwJ0J-PGJP1OKuGAg6LkdYgBs4xJYsEQ@mail.gmail.com>
 <CALjSBEvZ_5FU90D8ZaM9QjjPBvDPvgDKr+baTd3qSMyDOUyxhg@mail.gmail.com>
 <CAFe+wq3jGnnkQBuAnELraO5F529RiM6-Z6Pu19xZYBniej7Jxg@mail.gmail.com> <CALjSBEtB2EEs6hMCs119JjCXg0QxHR6ng2bP759CJ3vK318LQw@mail.gmail.com>
In-Reply-To: <CALjSBEtB2EEs6hMCs119JjCXg0QxHR6ng2bP759CJ3vK318LQw@mail.gmail.com>
From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 18 Sep 2024 16:17:33 +0530
Message-ID: <CAFe+wq1tzV86fZSUKPBEH4ywYWUcYLOEUBhe42o-nHqiyzVgiA@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Ming Hung Tsai <mtsai@redhat.com>
Cc: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>, Tony Asleson <tasleson@redhat.com>, 
	Zdenek Kabelac <zdenek.kabelac@gmail.com>, lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 18, 2024 at 4:14=E2=80=AFPM Ming Hung Tsai <mtsai@redhat.com> w=
rote:
>
> On Wed, Sep 18, 2024 at 6:25=E2=80=AFPM Lakshmi Narasimhan Sundararajan
> <lsundararajan@purestorage.com> wrote:
> >
> > On Wed, Sep 18, 2024 at 3:51=E2=80=AFPM Ming Hung Tsai <mtsai@redhat.co=
m> wrote:
> > >
> > > Hi Lakshimi,
> > >
> > > I'm glad to hear you've resolved the issue. If you're comfortable
> > > sharing, would you mind providing some insights into the root cause?
> >
> > Why not, fsync(thin dev) got incorrectly built leaving out a few
> > devices while syncing a pool with multiple thin devices.
> >
> > LN
> >
>
> Thanks for the update. Was it due to an issue during the kernel build
> process or possibly some custom patches? Also, do you still need the
> "dmsetup suspend/resume pool" workaround to pass the tests?



My _userspace_ application internally does build this sync list, and
due to a bug incorrectly, left some devices off.
No kernel layer issue was uncovered, and trying to recreate this
outside my application, as I already pointed out in the past,
was unsuccessful.

LN
>
>
> >
> > >
> > >
> > > On Wed, Sep 18, 2024 at 1:03=E2=80=AFAM Lakshmi Narasimhan Sundararaj=
an
> > > <lns.myspace@gmail.com> wrote:
> > > >
> > > > On Fri, Sep 13, 2024 at 7:49=E2=80=AFPM Tony Asleson <tasleson@redh=
at.com> wrote:
> > > > >
> > > > > You may want to check out https://lwn.net/Articles/457667/
> > > > >
> > > > > On Fri, Sep 13, 2024 at 9:06=E2=80=AFAM Zdenek Kabelac <zdenek.ka=
belac@gmail.com> wrote:
> > > > > >
> > > > > > Dne 13. 09. 24 v 7:55 Lakshmi Narasimhan Sundararajan napsal(a)=
:
> > > > > > > Hi Ming,
> > > > > > > I am still collecting results, so I will present findings tha=
t are
> > > > > > > confirmed so far.
> > > > > > > There is some good news too.
> > > > > > >
> > > > > > > On Fri, Sep 13, 2024 at 1:11=E2=80=AFAM Ming Hung Tsai <mtsai=
@redhat.com> wrote:
> > > > > > >>
> > > > > > >> Hi,
> > > > > > >>
> > > > > > >> On Wed, Sep 11, 2024 at 12:05=E2=80=AFAM Lakshmi Narasimhan =
Sundararajan
> > > > > > >> <lsundararajan@purestorage.com> wrote:
> > > > > >
> > > > > > > My application that is consuming the thin device pumps IO tra=
ffic
> > > > > > > directly on the raw block device.
> > > > > > > My application also keeps a journal record outside the thin p=
ool and
> > > > > > > after power recycled, reading the data back
> > > > > > > did not guarantee sync consistency.
> > > > > > >
> > > > > > > I wrote a sample program that is trying to recreate this outs=
ide my application.
> > > > > > > here it is: sulakshm/iotest: iotest (github.com)
> > > > > > > I am still refining it, as I have not seen the problem with t=
his tool yet.
> > > > > > > But the logic is similar to how my application consumes thin =
dev; and
> > > > > > > my app can reproduce this very easily.
> > > > > > >
> > > > > > > As I said before, I am still collecting additional informatio=
n from
> > > > > > > many internal tests.
> > > > > > > So far, I can see this problem even in 6.5 kernel.
> > > > > > >
> > > > > > > The latest distro/linux kernel where this problem is seen.
> > > > > > >> 6.5.0-15-generic #15~22.04.1-Ubuntu SMP PREEMPT_DYNAMIC Fri =
Jan 12 18:54:30 UTC 2 x86_64 x86_64 x86_64 GNU/Linux
> > > > > > >
> > > > > > >
> > > > > > > There is a workaround to this problem that is looking promisi=
ng, tests
> > > > > > > ongoing still.
> > > > > > >
> > > > > > > The sync point from my application is a sync(fd) of the thin =
dev.
> > > > > > > This has proven insufficient.
> > > > > > > In addition, I had to perform "dmsetup suspend pool -> dmsetu=
p resume pool".
> > > > > > > This guarantees sync point consistency.
> > > > > > >
> > > > > >
> > > > > > Hi
> > > > > >
> > > > > > Not exactly sure what your app is all exactly doing - however t=
here is
> > > > > > cut&paste from 'fsync()'  manpage:
> > > > > >
> > > > > > ---
> > > > > > Calling fsync() does not necessarily ensure that the entry in t=
he directory
> > > > > > containing the file has also  reached  disk.   For  that  an  e=
xplicit
> > > > > > fsync() on a file descriptor for the directory is also needed.
> > > > > > ---
> > > > > >
> > > > > > For this purpose our 'test suite' app basically  'opens' whole =
device and
> > > > > > fsync and close it - to ensure synchronization point flush.
> > > > > >
> > > > > > Thus 'suspend & resume' of the whole thin device could be possi=
bly unnecessary
> > > > > > - just do a fsync() on blockdevice fd.
> > > > > >
> > > > > >
> > > > > > You can also play fun games with 'fsfreeze' operation.
> > > >
> > > >
> > > > Good day all!
> > > >
> > > > This issue has been rootcaused successfully to an issue with my app=
lication.
> > > > It had been a tough last week given the nature of the issue, and
> > > > thanks for everyone who reached out with helpful suggestions.
> > > > As part of this process and bug verification, I would gladly submit
> > > > that the thin pool implementation did withstand the power cycle tes=
ts
> > > > wonderfully.
> > > >
> > > > Best regards and you all have a wonderful day.
> > > >
> > > >
> > > > > >
> > > > > > Regards
> > > > > >
> > > > > > Zdenek
> > > > > >
> > > > > >
> > > > > >
> > > > >
> > > >
> > >
> >
>

Received: from mail-pg1-f179.google.com (mail-pg1-f179.google.com [209.85.215.179])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F1EB1B81D8
	for <lvm-devel@lists.linux.dev>; Mon,  9 Sep 2024 14:48:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.179
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1725893295; cv=none; b=oQaymr/OhJrla6lo8fn5dCgcytdwMOzGZfc9+92kEQ2qhy78/Y/SS3omSOw60Ax4xuKjSTTg3fibuof0Ez/9O7LPGCNtdniSdAp3gEH0YAjv9JRsKSZiZVBWEdc0ZgZwbOpdaZGwW5lRLT+lv3E5orZJV4WqVBwPupUHRIznbxQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1725893295; c=relaxed/simple;
	bh=rRxnB9pc2M9lSR8Kc3GzAVZQIEUsjz8TErfLEzjXdis=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=JdGN+lwVLxutH5rz8ckuNmtdZteVu3UFRlWhMv7W0wSMM0n2oT4QG+dKnS4aWTNKJdk8PzZHyA2X2xdcpLPdo5xfrShehNqohEuXPu0snZYVH8cmspkZzSVZab8oMfP2OQuZPeHoloH4qpAxkrgfEScNCyFok5K3Rd3Bs35w5ww=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=j1ypm/WC; arc=none smtp.client-ip=209.85.215.179
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="j1ypm/WC"
Received: by mail-pg1-f179.google.com with SMTP id 41be03b00d2f7-7d50e7a3652so2381113a12.3
        for <lvm-devel@lists.linux.dev>; Mon, 09 Sep 2024 07:48:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1725893293; x=1726498093; darn=lists.linux.dev;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=hVmIJMpV+EVtMTACsizFa0zumzV6b+R2EYdtGqoo4MA=;
        b=j1ypm/WC/E+G+KQaCLe69fW0KhY2N8OfIZ67AbPsijST2X20LxF995uH+Tz2HktSSJ
         RkAcdfUmANvPwE3FUisWToUwiAg/50Ng68DnyxtQVVd15knOU8EwaMTikJi0ULlDyXDA
         wTYr48Rpdy1teEBL/OaHPBmQqAwq67Og1Hxfow+966s3XuGgWxtsgJ45gGytilwjrGQc
         OAca8M/HCag/TyvYld2cSMUd952BmMzuUeeP1ttXyYSbpPr1RB9NgM4eXVrwz2pO7Aia
         j+UXMKAaKOjO6wQjwCFzuLo9klcSC04IloTi6ZASGexqrXTKBCLijDZmVZEzN44yGVVv
         +x9A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1725893293; x=1726498093;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=hVmIJMpV+EVtMTACsizFa0zumzV6b+R2EYdtGqoo4MA=;
        b=qcaM7tQEr4VILrq3n3lXZk52CJ8KV76WDxpQcR4fZXXtWkqK2zwmFlRN7t7Rpi9NPp
         TWLQWlNwT4H8VmWsCOwu+qIaOC0TdK0jt/g1tSuaRYJpVACbNdBjN00m9s9bdW4xzr41
         VNsbn6mlTU3nNNBTA2OiMpzEWqIdm8fLM9kdln5T2PFG24GxkMnASRui+VPwGR2fqr2l
         yADU4v3H9vyRMQDyc+IWCLNgYg5zRPDuE0xbdJ2hwM5GZmqJwUCz9qZ79fghwqZzNxys
         yADX+mscqaqUYPbyRXV9n0rze0deKaZcFOP6MuvbawUgodElDcrLkwiC8y49KnEn3gCo
         1z+A==
X-Gm-Message-State: AOJu0YxPPG949CfakAvPysj6xTRjulUx96eJC1r2jmsmBPgM4RSdvwG8
	7glbCOl/SBcJqmmAMicVVUXNG9tT0A4iAkDxPu7YMSh3umnde7HQP/yENxjzRm6cJeOWp3cI2F6
	jw7L8n+Jnt6daDgsHjOShCRNio2PYmjGi
X-Google-Smtp-Source: AGHT+IFqv2V6XwE3/GKjuw3MSe60DBOm/y7oxrfyaLd5o7a5/FX1MPT0LNB9vkzPYqn4yL+UihKo6X+/28csmm1etck=
X-Received: by 2002:a05:6a20:c891:b0:1cf:4ad8:83b9 with SMTP id
 adf61e73a8af0-1cf4ad8912amr1160078637.43.1725893293332; Mon, 09 Sep 2024
 07:48:13 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
 <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com>
In-Reply-To: <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com>
From: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Date: Mon, 9 Sep 2024 20:18:00 +0530
Message-ID: <CAHJKXw1Xc7fabs=JOjgcuh8vTwkVMRvN2Mx9UO3Dfm8iZxxZ-w@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Cc: lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 9, 2024 at 6:57=E2=80=AFPM Zdenek Kabelac <zdenek.kabelac@gmail=
.com> wrote:
>
> Dne 08. 09. 24 v 3:37 Lakshmi Narasimhan Sundararajan napsal(a):
> > Hi Team,
> > Greetings!
> >
> > In my experiments with thin pool and power cycle tests, I find that
> > the inflight data has not been persisted, even if there is a sync
> > following write that got completed.
> >
> > suppose we have the following bdev stackup:
> > bdevs(multi) -> mpath -> lvm pv -> lvm vg -> lvm thin pool -> multiple
> > thin vols.
> >
> > Each of the thin vols that has inflight data, has a corresponding sync
> > checkpoint periodically. The expectation is all writes before the sync
> > are persisted to disk and can survive power reset tests.
> >
> > Like below seq on many thin vols on the thin pool.
> > write -> write -> write -> fsync(fd) -> write -> write -> fsync(fd) -> =
..etc
> >
> > Now my code only does a fsync(fd) on the thin volume (block device dire=
ctly).
> > There are no fs mounts on the volume.
> > Is this sufficient or should the thin pool (/dev/mapper/pool) also be
> > synced along?
> > What would be the proper sequence of sync actions to survive a power re=
set?
> >
> > I am also trying to validate if this is an issue because mpath is
> > involved in any way(another dm layer in between), but would appreciate
> > some guidance in this
> > regard.
>
> Hi
>
> Could you please retest your issue with  recent lvm2  (>=3D 2.03.24) and =
recent
> linux kernel   >=3D 6.9

Thank you for your quick attention.

That is a big jump.
Would you be willing to consider any distro (say OCP latest?), that
will come with a bundle for both lvm+kernel, is there any such
combination you would consider for this test?
Also, is there any way I can check issues/fixes of interest?

Is my logic using fsync(thin pool device) sufficient to pass power fail tes=
ts?
Are there any stronger versions or more logic to ensure power reset test pa=
sses?

Regards

>
> Regards
>
> Zdenek
>

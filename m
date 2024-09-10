Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 043EA19DF85
	for <lvm-devel@lists.linux.dev>; Tue, 10 Sep 2024 15:53:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1725983585; cv=none; b=MkmB4rXLoSvkC8235+ZqC4Y7wJi7I2HWbwCh1WRMPXOzi/lZvet8ghXXPmHl1yhi/68Y8a0UvOvavLCbBJYaPcUm9Vz1IVV+C6K6XTPWVACmwqB/q9K+eorVWImUmuNoohxJg6T8dJmY0IFGHHuatGRlH8iM7BLLJ8tF3/ZTOoo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1725983585; c=relaxed/simple;
	bh=Vli6YiuiSsFGsrS7WnTuLL7CrL/lKgL/Za4UwOyJMss=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=HMm09Su5PKXwMVQXVq5nN/d6axoKT15ZAoCm23CGH84eYJuX4KZxERQAh1il/9XElOgYTrce4di0b35g7iqdqa3xtvjYSv0U2dssDqLwWjrMq8P6ikHMlbFrQx7RiiTOTM0KGqW+lLd3M4wEQtAewVPJVMhS3XE59VAPHJ0cUS8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Uqb5nRJn; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Uqb5nRJn"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1725983582;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=3Lxp3AseEoH/RAmfXZGsqiMI0szOk1msz3OhCyml5QQ=;
	b=Uqb5nRJnVh/YsmmX8G+IKHCX5+rYbVaytkNhw4g6IOwzFKV2TfmPjHtOm/nw0bJKg+XqXb
	//P9IGfPr5scVq2rB5AkgnyrGo0EhUO+8VSOJiXsC7pcyiwkr/eEMHTBzCWycuUegsVqMy
	y8CCqbRyF3BigWdbEuwTGQklzAuhoL4=
Received: from mail-oa1-f71.google.com (mail-oa1-f71.google.com
 [209.85.160.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-364-U_hUzRJlNFaaOQGViUIOvw-1; Tue, 10 Sep 2024 11:53:01 -0400
X-MC-Unique: U_hUzRJlNFaaOQGViUIOvw-1
Received: by mail-oa1-f71.google.com with SMTP id 586e51a60fabf-277e5e84a54so5636768fac.1
        for <lvm-devel@lists.linux.dev>; Tue, 10 Sep 2024 08:53:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1725983581; x=1726588381;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=3Lxp3AseEoH/RAmfXZGsqiMI0szOk1msz3OhCyml5QQ=;
        b=ZOXb+KUBg4HodRjmlCTV+wI4S4COduj1pmxNY4lyme13HCEp2MQ8lD9MRTK2rwmucA
         lnljN5B5mxhPRZISu74cSBvQTHfCGszEDsal2FqLzUwFs6U9szndhr7caCBHMmJ6t46H
         F20C66pWHcpuiIGX6J4+oEauOMnYtkbShzXocRAg142NeMx0WlYwY/hJLflj4uxasuFp
         qcnGgtDbgUl1oV8tK7zYXvkpofqdlUL23fK4Gzwbfgb4kb3RRMvKNW0HntHtSrAeVzMK
         ixuaqXJVJC0tvszW/31Ocl9h0lZi27s1wlemVtDTGzm28gpAx9vzm3vV2jn0f7tBJPWM
         AWlA==
X-Gm-Message-State: AOJu0YwOFhmesGIh5EOcRjcMCzjubjvX7XaaVTW5hEj+L5sjKU7hB0t0
	DkroHpHe5+Hllj2cU/r17GE1PpKMQFIuauHqEc0H9AKf+N2y70jRVz755el+bkjOECpprsnFvjy
	U/n0gqCdn6kDOXQMrwZHjSIBVJsjbgHIOxl3QgONRSynDjLy7YakkYlDnKJCW/kMtgq+q3+tyKu
	gzrO9DLNGtAZlx0/DA0vHNu9TXA/jWAFc=
X-Received: by 2002:a05:6870:700e:b0:261:f30:fda3 with SMTP id 586e51a60fabf-27b82e8118cmr10043888fac.21.1725983580833;
        Tue, 10 Sep 2024 08:53:00 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IEqD18e0spSZcXxoWxTaw5diQ46SFcxGXlRuSrhuPkJGh6vFyKEeL4Wx6HsiHbBEwwxF5O0md5NH7wfFf2bPTw=
X-Received: by 2002:a05:6870:700e:b0:261:f30:fda3 with SMTP id
 586e51a60fabf-27b82e8118cmr10043870fac.21.1725983580446; Tue, 10 Sep 2024
 08:53:00 -0700 (PDT)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
References: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
 <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com> <CAHJKXw1Xc7fabs=JOjgcuh8vTwkVMRvN2Mx9UO3Dfm8iZxxZ-w@mail.gmail.com>
In-Reply-To: <CAHJKXw1Xc7fabs=JOjgcuh8vTwkVMRvN2Mx9UO3Dfm8iZxxZ-w@mail.gmail.com>
From: Ming Hung Tsai <mtsai@redhat.com>
Date: Tue, 10 Sep 2024 23:52:49 +0800
Message-ID: <CALjSBEu7FA7Fv87P51vkiL98jRG42R3rkf2RUuxTEjHoQHMwdA@mail.gmail.com>
Subject: Re: thin pool powerfail tests and data loss
To: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>
Cc: lvm-devel@lists.linux.dev
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 9, 2024 at 10:53=E2=80=AFPM Lakshmi Narasimhan Sundararajan
<lns.myspace@gmail.com> wrote:
>
> On Mon, Sep 9, 2024 at 6:57=E2=80=AFPM Zdenek Kabelac <zdenek.kabelac@gma=
il.com> wrote:
> >
> > Dne 08. 09. 24 v 3:37 Lakshmi Narasimhan Sundararajan napsal(a):
> > > Hi Team,
> > > Greetings!
> > >
> > > In my experiments with thin pool and power cycle tests, I find that
> > > the inflight data has not been persisted, even if there is a sync
> > > following write that got completed.
> > >
> > > suppose we have the following bdev stackup:
> > > bdevs(multi) -> mpath -> lvm pv -> lvm vg -> lvm thin pool -> multipl=
e
> > > thin vols.
> > >
> > > Each of the thin vols that has inflight data, has a corresponding syn=
c
> > > checkpoint periodically. The expectation is all writes before the syn=
c
> > > are persisted to disk and can survive power reset tests.
> > >
> > > Like below seq on many thin vols on the thin pool.
> > > write -> write -> write -> fsync(fd) -> write -> write -> fsync(fd) -=
> ..etc
> > >
> > > Now my code only does a fsync(fd) on the thin volume (block device di=
rectly).
> > > There are no fs mounts on the volume.
> > > Is this sufficient or should the thin pool (/dev/mapper/pool) also be
> > > synced along?
> > > What would be the proper sequence of sync actions to survive a power =
reset?
> > >
> > > I am also trying to validate if this is an issue because mpath is
> > > involved in any way(another dm layer in between), but would appreciat=
e
> > > some guidance in this
> > > regard.
> >
> > Hi
> >
> > Could you please retest your issue with  recent lvm2  (>=3D 2.03.24) an=
d recent
> > linux kernel   >=3D 6.9
>
> Thank you for your quick attention.
>
> That is a big jump.
> Would you be willing to consider any distro (say OCP latest?), that
> will come with a bundle for both lvm+kernel, is there any such
> combination you would consider for this test?
> Also, is there any way I can check issues/fixes of interest?
>
> Is my logic using fsync(thin pool device) sufficient to pass power fail t=
ests?
> Are there any stronger versions or more logic to ensure power reset test =
passes?
>
> Regards
>
> >
> > Regards
> >
> > Zdenek
> >
>

Hi,

Could you please provide more details on the steps you took that led
to the issue?
Additionally, if possible, it would be helpful to let us know if the
issue is reproducible on Fedora 40, with or without the mpath layer.


Thanks,
Ming-Hung Tsai


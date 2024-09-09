Received: from mail-ej1-f52.google.com (mail-ej1-f52.google.com [209.85.218.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE3BA1B1510
	for <lvm-devel@lists.linux.dev>; Mon,  9 Sep 2024 13:27:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1725888432; cv=none; b=gYI/+fYm8zVT5kaI/ZY/JCl4CGOQ+bfcdoz4MuVLObePMBvpcgDPyZHXu1/I5XzkOnClgfzjf6jpS52IlFKwEN0+NPqRJ3hvZxC3dPIK+1pCu1CT38bFw1LsFvIXhjTBkBnN7hYJh/vINcDKFMME3tNJ09b+fOny4YH241+45GI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1725888432; c=relaxed/simple;
	bh=6iyzQ3GWANgTvbCOgtkelIfj8dS/90vfDuuKQksFliU=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=Eve5CObCsVGmbuS8glI0nVsE0y75gFN017KHu6PsmU6Pn6aLz/iVvXWGjvPonxUsX+qSqM9bBPdeRdxgG/qHAD7tNRbGEhmWW0lB6IvLxykqj2ROkrICWK8BQi+CF0k+Zq8V9OlFFCohTwv98nLDtts0zUFeaf11o+BZiuXs0DM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Z//SE9D8; arc=none smtp.client-ip=209.85.218.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z//SE9D8"
Received: by mail-ej1-f52.google.com with SMTP id a640c23a62f3a-a8d446adf6eso169017966b.2
        for <lvm-devel@lists.linux.dev>; Mon, 09 Sep 2024 06:27:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1725888428; x=1726493228; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=kin9GjHhPImVoV3fboADCeLF/zC4mXQEO1r9lHpSW3Y=;
        b=Z//SE9D8nIwZotXhhnKFmvNhUgeBIjJupG6C21NpTgQc/M3pnAn10vxXSxnPURB4mV
         4XzYYnNizHiNXswHKFTl+gNkOLMvi5gZwZwQqdmGvxL9X8lg4o3EaS6CNkGZ0rBre1jn
         u23gl66xDSFgj8Ns1UWY7pVJHD2jiHT5bewNf5ujCu2Qrwwh5FeedYnIWY815PX0KKdi
         RwzZruMkFq3+FvCupU/INq/V1YZ1NiwCxOLC5aETDUeJsc58+CaYgMPPWk2Gw40Fo5fM
         EKoNh3a0FODiRw+Fs/Zviaoo7EMZ98pz6yWCBtU9DlhrOagZxIhxHOUNArw7HoyH+pe0
         NIcQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1725888428; x=1726493228;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=kin9GjHhPImVoV3fboADCeLF/zC4mXQEO1r9lHpSW3Y=;
        b=HeUEz5IKEFNJK60fDecQa4Blu+Q3MPFMZBW2BDadObuXL6yg3IBa3bUY89Dk1QRyIV
         a/SM+2L+xb/XPUVtmM2TwC/NBfqj+fXlQF1fBy5nVNhOb8nGXw4zjcvmOX20fjWqLuKu
         HjJ5V6UrS8ps9YR/VEL/cejySEj8UMWOy0qpXhiRKS9mUxneQPiaeFAyQjcapsDv4trv
         LtqIxh8DLl/SyckUN4+IGkCizI1JtdiC06glpEUQR/9nPXQMo4hIzaNgXLd7cV8dPZmE
         SSCK/T1V//DhTEBAgZJtJB2qgPq+KOA1FHSYuE7kg/VPKG5bgXvbVA54oA1PUR3/v2jo
         0rEw==
X-Forwarded-Encrypted: i=1; AJvYcCXHbug1f/PL1jiwpSANbqlGIgVSRsvm0Tb91+MY4nR+deuPxiKWrS58fI9Y6zqCJBwPl+cPP8JKs2I=@lists.linux.dev
X-Gm-Message-State: AOJu0Yy9jLkH0uBkT/TNcybGGLt/gO30SuBsL5A6xUMkwgvRJxdPrG2o
	oYB3Ya55UuvBV1UaSFzRMBlfofQ83SqZgarB6MaUuORF9whhexiu
X-Google-Smtp-Source: AGHT+IFyb63Vj/ZdMYWzNrGnjmB4OVZpD8HNRwzrtReJmHSHCKAak49ZfQwvPLk6GrScKaWrDzTsiw==
X-Received: by 2002:a17:907:f789:b0:a7a:a212:be4e with SMTP id a640c23a62f3a-a8d24513c99mr510833766b.7.1725888427913;
        Mon, 09 Sep 2024 06:27:07 -0700 (PDT)
Received: from ?IPV6:2a03:a900:1000:7e9:403e:7c8b:351b:f333? ([2a03:a900:1000:7e9:403e:7c8b:351b:f333])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-a8d25d40e8csm342467966b.196.2024.09.09.06.27.07
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 09 Sep 2024 06:27:07 -0700 (PDT)
Message-ID: <5fde5c55-76d8-455b-8235-8826a098afa7@gmail.com>
Date: Mon, 9 Sep 2024 15:27:06 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: thin pool powerfail tests and data loss
To: Lakshmi Narasimhan Sundararajan <lns.myspace@gmail.com>,
 lvm-devel@lists.linux.dev
References: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
Content-Language: en-US, cs
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
In-Reply-To: <CAHJKXw1LiySXw3+iPQAAq9VodwaL+oaqGTb6frpzdxVCoWGRwA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 08. 09. 24 v 3:37 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> Greetings!
> 
> In my experiments with thin pool and power cycle tests, I find that
> the inflight data has not been persisted, even if there is a sync
> following write that got completed.
> 
> suppose we have the following bdev stackup:
> bdevs(multi) -> mpath -> lvm pv -> lvm vg -> lvm thin pool -> multiple
> thin vols.
> 
> Each of the thin vols that has inflight data, has a corresponding sync
> checkpoint periodically. The expectation is all writes before the sync
> are persisted to disk and can survive power reset tests.
> 
> Like below seq on many thin vols on the thin pool.
> write -> write -> write -> fsync(fd) -> write -> write -> fsync(fd) -> ..etc
> 
> Now my code only does a fsync(fd) on the thin volume (block device directly).
> There are no fs mounts on the volume.
> Is this sufficient or should the thin pool (/dev/mapper/pool) also be
> synced along?
> What would be the proper sequence of sync actions to survive a power reset?
> 
> I am also trying to validate if this is an issue because mpath is
> involved in any way(another dm layer in between), but would appreciate
> some guidance in this
> regard.

Hi

Could you please retest your issue with  recent lvm2  (>= 2.03.24) and recent 
linux kernel   >= 6.9

Regards

Zdenek


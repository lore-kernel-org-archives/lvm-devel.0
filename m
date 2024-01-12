Received: from mail-ej1-f47.google.com (mail-ej1-f47.google.com [209.85.218.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E90FE58222
	for <lvm-devel@lists.linux.dev>; Fri, 12 Jan 2024 10:45:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jeTO3Z2m"
Received: by mail-ej1-f47.google.com with SMTP id a640c23a62f3a-a26f73732c5so744084566b.3
        for <lvm-devel@lists.linux.dev>; Fri, 12 Jan 2024 02:45:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1705056309; x=1705661109; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :from:to:cc:subject:date:message-id:reply-to;
        bh=FkWArslYTYul+NvKaTbBggo6z0GZFg5qmOGj2TnA2kw=;
        b=jeTO3Z2m6mn8cAJYg5H4rukYjEYfBGKt+XX4/5Whbj9nOMtr3I8N35aKy4i6Jab8yn
         BDE+Pwhj84aUyUYqd5gFxn5vl0NzDHpndY1L9GVgsMcws2zDE2xi4mtpK/RKez+tc6Ir
         vsNxxrV7QiapRL1Hp76uyX8XGxUxFuR5OKJSnzWFYgjqMJV6+6f33R5UkOjcW722of3+
         EiNiYGR3OPf/GfwTPaY0Sr9GjtAEsEFHaxRzeT8EjUcErU/+Q/WI55pVU8QPkzcz4KQP
         i93YVlvPEEkkuixA0Lg0ZYZzt4mobqMBUPPp013lsxErTUmoYx9ENuwuB1vUF+OzVVl/
         4itw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1705056309; x=1705661109;
        h=content-transfer-encoding:in-reply-to:from:references:to
         :content-language:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=FkWArslYTYul+NvKaTbBggo6z0GZFg5qmOGj2TnA2kw=;
        b=pckw5HH3x+atqmqdhZjN8tNQd90gHXNOl2PC6qbLm56Bd3bTO0cR9PiSbcnRWJpOux
         qlCDqq1IaAR/MjAE44wYDTgSxIYDOPKxxfpIXJ+zaAwMDia5WIG+qTLP05x33OOCBGYf
         nTOrLq1JWNAZMA1+PZmKnHu4dnNrpyAgNYzUVXAx0tTFmuKFtD5LJnex8oZjMmMWNj4H
         7JNFrquqH4l8/HyVUiL0MmDBajeRqLJrlHOaRvB07UY6WGq/YHAkgI73SRq7G66XPK5H
         zHFpl+VUanZLWM0JrzPgNOW1zvmCLzslc1I446RIs5PXjHYbPkm5Jw27Qt/PV35CHoFT
         YeAg==
X-Gm-Message-State: AOJu0Yzp5mkv84+NlR53iFN5dsfI4l7y5R3RSHs1uC5I2lew+zrTQQlt
	Dq5UqbgDCp870Df3fgMm0UPnv5Y18zjNxQ==
X-Google-Smtp-Source: AGHT+IFYv0ryf5PPHAEsmGPTrGkE91EKlYJkGnfPp+hkaQmenx3ndhISF97kL6b+VqZFaUw5JFOl7A==
X-Received: by 2002:a17:906:aaca:b0:a2c:ec05:9cfc with SMTP id kt10-20020a170906aaca00b00a2cec059cfcmr86053ejb.143.1705056308947;
        Fri, 12 Jan 2024 02:45:08 -0800 (PST)
Received: from [192.168.0.99] ([94.142.239.37])
        by smtp.gmail.com with ESMTPSA id rn21-20020a170906d93500b00a2bbed0facesm1671360ejb.177.2024.01.12.02.45.08
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Fri, 12 Jan 2024 02:45:08 -0800 (PST)
Message-ID: <6cb99dad-259a-4b9f-9d2b-c57fc1bf23ce@gmail.com>
Date: Fri, 12 Jan 2024 11:45:07 +0100
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Reg thin pool and discard handling
Content-Language: en-US, cs
To: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>,
 lvm-devel@lists.linux.dev
References: <CAFe+wq3F1TCe9c6VXXiHFcA2Fys_L6+0Jv8FmDy8aH-0HfsOqw@mail.gmail.com>
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
In-Reply-To: <CAFe+wq3F1TCe9c6VXXiHFcA2Fys_L6+0Jv8FmDy8aH-0HfsOqw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 11. 01. 24 v 4:41 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> A very happy new year to you all.
> 
> When a thin pool is created it has option to control discard behavior.
> Typically the useful ones are either discard_passdown vs no_discard_passdown.
> 
> My question is as below:
> If the thin pool is in "no_discard_passdown" and later changes to
> "discard_passdown", would there be a way to reinitiate discard for
> those ranges that was not passed down?
> 
> Typically fs sitting on top of the thin lv controls discard ranges and
> that was already handled as "no_discard_passdown".
> Later if say, the backing storage gets filled up, then how can one
> re-initiate discard again to allow it to reach
> backing storage?
> 

Hi

When you run   'fstrim' operation on freshly mounted fs  it should trim
all the areas that are empty.

There is also an offline tool   'thin_trim'  - see  man thin_trim(8)
maybe that's exactly what you are looking for ?

But in this case it would need some dmsetup manipulation as
lvm2 is not supporting ATM 'component activation' in RW mode
(might be probably worth to add such support for cases like this - but
we would like to track such stuff in metadata so it needs some thinking)

Regards

Zdenek


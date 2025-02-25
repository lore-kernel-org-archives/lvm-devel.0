Received: from mail-ed1-f41.google.com (mail-ed1-f41.google.com [209.85.208.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03C10265617
	for <lvm-devel@lists.linux.dev>; Tue, 25 Feb 2025 09:03:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740474206; cv=none; b=uy0StIkyNXIeZ8T4yZSzf9ULe8Jksedn0atltkdrUeiBjQUy1yUAf0IIDVgbPpPDsGjQIc6gAqfqUVNvGWQQUUQh+zaSM1JHEuWPvJjADyL13P/35fy19TsIdpqt20ML9iTaeoMyLo9qX9DI51u7E2XslYMD8UrMaw7V2JFYgWA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740474206; c=relaxed/simple;
	bh=z8Jz6RDf5Sc3Q0Rb8skLljRgwHnBSLznQpxYY+xP3CE=;
	h=From:Message-ID:Date:MIME-Version:Subject:To:References:
	 In-Reply-To:Content-Type; b=e1qgWb0vy0HgujfpdT3gPOuCp14vGQmU5SyUrq7XVUMB+FYS7CAm9bZm1hCA4TBJbPQs0vaE/NQNZT7jedFk85NhBwydbxWc8tuZbamFE+yk5j17y59Ep9LHxpIm0qcjrWljjcelBH17CXSdPclkjcOmyTMKUkfcyzU2vzz1Ggg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=bex/GB/X; arc=none smtp.client-ip=209.85.208.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bex/GB/X"
Received: by mail-ed1-f41.google.com with SMTP id 4fb4d7f45d1cf-5ded69e6134so8785621a12.0
        for <lvm-devel@lists.linux.dev>; Tue, 25 Feb 2025 01:03:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1740474203; x=1741079003; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:content-language:references
         :to:subject:user-agent:mime-version:date:message-id:from:from:to:cc
         :subject:date:message-id:reply-to;
        bh=MXfHQJL8zJheVCPM+KHjOZanh4aEHSXOhGCnzft5KqY=;
        b=bex/GB/XjblJyg/+X6MHH08Z3qkHUiQI/5LRGplszXTS54Hmc/DrKATT67zw+vocvL
         qraoi1z2XZPmGGHwUR3g9HIC3HSgJqm7Wvf6palZ8xPOrEtNNlWjkEPqNxXoiIuitXE2
         SWmdzo5lenoPFasEU5nGjbBLgF5xdxaogCOVo2oty66n0lWWxz+ni8JAVEsmHLaoWHoO
         HKedk/We+GIUGak/n8WLeYOHjVMGVp5y/M43NN450dshBwfRg7tFfAjYrWAojN0pepKq
         CvrWhmCzc46LvvelwLxV2p/P+42IMpPD3OIEhowi6ff1jPsdtrydRvsbeEM9iyZZrP8q
         5RiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1740474203; x=1741079003;
        h=content-transfer-encoding:in-reply-to:content-language:references
         :to:subject:user-agent:mime-version:date:message-id:from
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=MXfHQJL8zJheVCPM+KHjOZanh4aEHSXOhGCnzft5KqY=;
        b=PImmPhcUfnn1YGWJB44QqSt8+6qUvhu4OHPROKoY0Ajx2UhmfAn0jRqg9+BvlPukZh
         WmUh5quMcrq2R7/RSroM9xfwuSbNsXGImCE1PU7jlzUklXV4HlUhO+niKuCHvOp3Kn8y
         VL/BXRGgHovsQEaBLW3TBJSCu1EtCpVP9YuQO7iBfYm37+qziFwQ6c8ra+FY7fpvW4It
         BSShpc65lZ+u0TQGDWT2ARh1hwFNga9Szzw5Kr58dp27pwTogiFYywlGAja8g4aUqnl8
         +LCJyynnCozhEmzK9xk7bmrSZGaqP9c4c/EBKwS3/P/f6LCbCdkF6ri1QO8D6qm5mVAx
         5Vfg==
X-Forwarded-Encrypted: i=1; AJvYcCWM/dZgxYVFJNNQRAQXO0jalo+asTNEHfTBCyODWDJdMeGAP5wXX7iUHpBtVNFikQnJy5CIuNSdbBk=@lists.linux.dev
X-Gm-Message-State: AOJu0YwogT2gADqmB5Fvz2k7kKu/+tVpLYVwnrEJV6RlWZe2kcM82YTN
	vDdrKIjgVOwQY05RmJuyKuGtBEcVrgCDfpka7mXArouWYq0V5jCx
X-Gm-Gg: ASbGncub++ZwxtNeCnS/aFbIc6Tays6iOIHTjm7TA1CSlbXkx6oJQ05rj8a/f1y+6Mb
	JlFLiM/UAk1R5j8NsxHwIGq/Yt7+3/GucSCrZ3DYnufynd9vc5j2aZoXi7IgqkjIRyI0dy6wdBA
	Wtw5bk+i9xOlq2LE1Eu2CjmDcJzgKo35yozYY6EjBE5dvDY9M7oRUNCMfRi6l0zgblFVpHyDRLv
	qe+LK3a448GAeNYBjsnQKi0x/k/Fd8MQpJNV6oLca4vezHjFOXqELaw9aXdHBvTg5BWjxaothwx
	Jl9yrPeyRL0/6UZJIcAUD20q9PXTdI7XMw/MDpmOF88xq+rGeKcLk4cnJUPZD2DBnKRlfjGPDA=
	=
X-Google-Smtp-Source: AGHT+IE9j1WLt3F/I4dYLYjCYlsBykV12Hxy5nMX5mRUwNh0XN1s8z13LVMQbpl4JvWQ5L3voBwyxg==
X-Received: by 2002:a05:6402:254d:b0:5d0:f9f1:cd73 with SMTP id 4fb4d7f45d1cf-5e0b70d6756mr17366250a12.13.1740474202857;
        Tue, 25 Feb 2025 01:03:22 -0800 (PST)
Received: from ?IPV6:2a03:a900:1000:7e9:403e:7c8b:351b:f333? ([2a03:a900:1000:7e9:403e:7c8b:351b:f333])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-5e459c3fb4bsm893853a12.16.2025.02.25.01.03.21
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 25 Feb 2025 01:03:21 -0800 (PST)
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
X-Google-Original-From: Zdenek Kabelac <zkabelac@redhat.com>
Message-ID: <a1a455c4-7363-4f41-a634-db0a8d6ecb19@redhat.com>
Date: Tue, 25 Feb 2025 10:03:20 +0100
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: dmsetup.8: Some remarks and a patch with editorial changes for
 this man page
To: Bjarni Ingi Gislason <bjarniig@simnet.is>, lvm-devel@lists.linux.dev
References: <174022250690.11933.16308959540537242873.reportbug@kassi.invalid.is>
Content-Language: en-US, cs
In-Reply-To: <174022250690.11933.16308959540537242873.reportbug@kassi.invalid.is>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 22. 02. 25 v 12:11 Bjarni Ingi Gislason napsal(a):
> Package: dmsetup
> Version: 2:1.02.201-1
> Severity: minor
> Tags: patch
>
>     * What led up to the situation?
>
>       Checking for defects with a new version
>
> test-[g|n]roff -mandoc -t -K utf8 -rF0 -rHY=0 -rCHECKSTYLE=10 -ww -z < "man page"
>
>    [Use "groff -e ' $' -e '\\~$' <file>" to find obvious trailing spaces.]
>
>    ["test-groff" is a script in the repository for "groff"; is not shipped]
> (local copy and "troff" slightly changed by me).
>
>    [The fate of "test-nroff" was decided in groff bug #55941.]
>
>     * What was the outcome of this action?


Hi


Thanks for lot of hints and ideas how to make lvm2 man pages better.

I'll try to update also our fully generated pages to produce more compliant 
output.

Your patches were upstreamed with few more my edits.


Regards


Zdenek


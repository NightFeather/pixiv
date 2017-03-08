# Pixiv
  
trying to make something that I can save some artwork on Pixiv through cli/bot.

## APIs Implementation

Using Pixiv's json APIs for its mobile apps, so there's no gurantee it won't break in the future.
Also It's created for saving artworks to local, so only apis for *illust info fetching* will be implemented.
Unless I want to make it work as a fully functioned Pixiv library someday.

## Usage

### Installation

`gem install pixiv, github: 'nightfeather/pixiv'`

also you have `ImageMagick` and `unzip` installed with commands: `convert` and `unzip` available.

p.s. convert is needed 'cause `RMagick` can't be easily configured when you have per-image delays.

### Initialization
Fetch essential oauth token.
It will auto refresh before sending request when expired.

Because `refresh_token` doesn't work properly on Pixiv's oauth endpoints, all of authorization needs your login credentials. Make sure instances of Pixiv::AccessToken won't be accidentally exposed.

```ruby
cli = Pixiv::Client.new 'your account', 'your password'
```

### Getting info
Fetch generic info of artwork

```ruby
cli.get_illust 'illust_id here'
```
will return object with corresponding class under `Pixiv::Illust`

For ugoiras, it will automatically make a extra request to fetch metadata

### Download
Download artwork.
your can custom filename with the template.

--

simple one: use default template and download silently and immediately

```ruby
resp = cli.get_illust 'illust_id'
dlm = Pixiv::Downloader.new
dlm.download resp
```
then grab then file right under current directory

--

complex one: pass your template in and callback

```ruby
resp = cli.get_illust 'illust_id'
task = resp.download_meta '?user? - ?title?'
task.progress_callback = proc { |file, length| puts "Write Whatever you want to complain during download here" }
dlm.execute task
```

## Example

```ruby
cli = Pixiv::Client.new 'your account', 'your password'
resp = cli.get_illust 44298467
dlm = Pixiv::Downloader.new
task = resp.download_meta '?user? - ?title?'
task.progress_callback = ->(file, length){ puts "#{file} - #{length} bytes saved"}
dlm.execute task
#=> /home/nightfeather/github/pixiv/pixiv事務局 - うごイラはじめました - cover.jpg - 1084323 bytes saved
#=> /home/nightfeather/github/pixiv/pixiv事務局 - うごイラはじめました.zip - 867212 bytes saved
```


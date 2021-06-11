# output "latest_linux_image" {
#     value = data.aws_ami.latest_amazon_linux_image.id
# }
output "server_public_ip" {
    value = module.myapp_webserver.web-server.public_ip
}

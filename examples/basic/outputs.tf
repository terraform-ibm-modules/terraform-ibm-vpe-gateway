output "vpe_ips" {
  description = "The endpoint gateway reserved ips"
  value = merge(
    module.vpes_batch_1.vpe_ips,
    module.vpes_batch_2.vpe_ips,
    module.vpes_batch_3.vpe_ips,
    module.vpes_batch_4.vpe_ips,
    module.vpes_batch_5.vpe_ips,
    module.vpes_batch_6.vpe_ips,
    module.vpes_batch_7.vpe_ips,
    module.vpes_batch_8.vpe_ips
  )
}

output "crn" {
  description = "The CRN of the endpoint gateway"
  value = concat(
    module.vpes_batch_1.crn,
    module.vpes_batch_2.crn,
    module.vpes_batch_3.crn,
    module.vpes_batch_4.crn,
    module.vpes_batch_5.crn,
    module.vpes_batch_6.crn,
    module.vpes_batch_7.crn,
    module.vpes_batch_8.crn
  )
}

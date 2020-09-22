export const UploadMedia = {
  mounted() {
    const cloudinaryUpload = cloudinary.createUploadWidget(
      {
        cloudName: 'bordo',
        uploadPreset: 'bdo_image_frontend_upload',
        sources: ['local'],
        show_powered_by: false,
      },
      (error, result) => {
        if (!error && result && result.event === 'success') {
          this.pushEvent('upload-success', {
            title: result.info.public_id,
            public_id: result.info.public_id,
            url: result.info.url,
            thumbnail_url: result.info.thumbnail_url,
            bytes: result.info.bytes,
            width: result.info.width,
            height: result.info.height,
          })
        }
      },
    )

    document.getElementById('upload_widget').addEventListener(
      'click',
      function () {
        cloudinaryUpload.open()
      },
      false,
    )
  },
}

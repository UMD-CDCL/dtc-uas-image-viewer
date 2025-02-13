#!/usr/bin/env python3
import tkinter as tk
import image_viewer

if __name__ == "__main__":

    # start app
    root = tk.Tk()
    ip = "10.200.91.52"
    app = image_viewer.ImageBrowser(root,ip)
    root.mainloop()

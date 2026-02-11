import { defineStore } from 'pinia'

export const useUIStore = defineStore('ui', {
    state: () => ({
        isSidebarCollapsed: false,
        isSidebarOpenMobile: false
    }),
    actions: {
        toggleSidebar() {
            this.isSidebarCollapsed = !this.isSidebarCollapsed
        },
        toggleSidebarMobile() {
            this.isSidebarOpenMobile = !this.isSidebarOpenMobile
        },
        closeSidebarMobile() {
            this.isSidebarOpenMobile = false
        }
    }
})

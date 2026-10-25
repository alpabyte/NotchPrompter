import AppKit

final class GlobalKeyboardShortcuts {
    private weak var viewModel: PrompterViewModel?
    private var globalMonitor: Any?
    private var localMonitor: Any?

    init(viewModel: PrompterViewModel) {
        self.viewModel = viewModel
        let mask: NSEvent.EventTypeMask = [.keyDown]
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.handle(event)
            return event
        }
    }

    deinit {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
    }

    private func handle(_ event: NSEvent) {
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask) == [.command, .option] else { return }
        guard let viewModel else { return }

        switch event.keyCode {
        case 35: // P
            if viewModel.isPlaying { viewModel.pause() } else { viewModel.play() }
        case 4: // H
            viewModel.isPrompterVisible.toggle()
        case 123: // Left arrow
            viewModel.decreaseSpeed()
        case 124: // Right arrow
            viewModel.increaseSpeed()
        case 126: // Up arrow
            viewModel.scrollUp()
        case 125: // Down arrow
            viewModel.scrollDown()
        default:
            break
        }
    }
}
